# frozen_string_literal: true

require 'fileutils'
require_relative 'create_intermittent_fail_issue'

CIRCLE_BUILD_URL = "https://app.circleci.com/jobs/github/agileventures/localsupport/#{ENV['CIRCLE_BUILD_NUM']}/tests"

# tools to help report intermittently failing tests as github issues
module ReportIntermittentFails
  # run command with output and return exit status
  def self.run(command)
    ENV['TEST_ENV_NUMBER'] = '2' # just in case this ever changes in future TODO - this feels wrong
    output = `#{command}` # so here we are relying on rspec config
    Config.logger.info '------------------------'
    Config.logger.info output
    Config.logger.info '------------------------'
    original_exit_status = $?.exitstatus
    Config.logger.info "original exit status was: #{original_exit_status}"
    original_exit_status
  end

  def self.run_endtoend_check
    run(Config.rspec_endtoend_command)
  end

  def self.run_rspec
    run(Config.rspec_command)
  end

  def self.rerun_failing_tests(issue_creator = CreateIntermittentFailIssue,
                               reporter = ReportIntermittentFails)
    unless File.exists?(Config.default_result_file)
      Config.logger.info "\nNothing to rerun\n"
      return
    end

    arrange_files
    original_exit_status = run_rspec
    FileUtils.mv(Config.temp_result_file, Config.second_run_result_file) # e.g. /examples-2.txt to examples.txt.run2

    # assume that ./spec/examples.txt.run1 is available from previous reassemble step
    failed_first_run_specs = `grep "| failed" #{Config.first_run_result_file} | cut -d" " -f1`.split("\n")
    Config.logger.info "\n#{failed_first_run_specs.count} first run failures\n"

    check_for_fails(failed_first_run_specs, reporter, issue_creator, original_exit_status)
  end

  def self.arrange_files
    FileUtils.rm Dir.glob(Config.results_files_wildcard) # this is to remove parallel run files
    FileUtils.cp(Config.default_result_file, Config.temp_result_file) # because TEST_ENV_NUMBER defaulted to 2
  end

  def self.check_for_fails(failed_first_run_specs,
                           reporter,
                           issue_creator,
                           original_exit_status)
    fails = reporter.list_intermittent_fails(failed_first_run_specs, logging: true)

    Config.logger.info "\nGithub Issue body info:\n #{body}\n\n"
    Config.logger.info "Submitting #{fails.count} intermittent fails\n"
    fails.each do |failure|
      Config.logger.info failure
      issue_creator.with(title: "Intermittent Fail: #{failure}", body: body, branch: build_branch)
    end

    exit(original_exit_status)
  end

  def self.list_intermittent_fails(failed_first_run_specs,
                                   logging: false,
                                   filesystem: File,
                                   filename: Config.second_run_result_file)
    Config.logger.info "reading lines from #{filename}"
    lines = filesystem.readlines(filename)
    failed_first_run_specs.each_with_object([]) do |failure, memo|
      Config.logger.info failure if logging
      memo << get_rb_file_name(failure) if passed_on_second_run?(lines, failure)
    end
  end

  RUBY_FILE_SUFFIX = '.rb'

  def self.get_rb_file_name(name)
    name[0..(name.index(RUBY_FILE_SUFFIX) + RUBY_FILE_SUFFIX.length - 1)]
  end

  def self.passed_on_second_run?(lines, failure)
    Config.logger.info "checking for #{failure} in file"
    lines.each { |line| Config.logger.info line }
    lines.count { |line| line =~ /#{Regexp.quote(failure)}.*passed/ }.positive?
  end

  # Move all the below to Config?
  def self.body
    "Build: #{build_url}\nCommit: #{build_commit}\nBranch: #{build_branch}\n Container: #{build_node}"
  end

  def self.build_branch
    ENV['CIRCLE_BRANCH'] || ENV['GIT_BRANCH'] || ENV['TRAVIS_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.chomp
  end

  def self.build_url
    ENV['BUILD_URL'] || ENV['TRAVIS_JOB_WEB_URL'] || default_build_url
  end

  def self.default_build_url
    "https://travis-ci.org/#{repo_name_with_owner}/builds/#{ENV['TRAVIS_BUILD_ID']}"
  end

  def self.build_node
    ENV['CIRCLE_NODE_INDEX'] || 'N/A'
  end

  def self.repo_name_with_owner
    Config.repo_name_with_owner || ENV['TRAVIS_REPO_SLUG']
  end

  def self.build_commit
    ENV['CIRCLE_SHA1'] || ENV['GIT_COMMIT'] || ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.chomp
  end
end
