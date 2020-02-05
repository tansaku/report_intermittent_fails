# frozen_string_literal: true

require 'fileutils'
require_relative 'create_intermittent_fail_issue'

CIRCLE_BUILD_URL = "https://app.circleci.com/jobs/github/agileventures/localsupport/#{ENV['CIRCLE_BUILD_NUM']}/tests"

# tools to help report intermittently failing tests as github issues
module ReportIntermittentFails
  def self.list_intermittent_fails(failed_first_run_specs,
                                   logging: false,
                                   filesystem: File,
                                   filename: './spec/examples.txt.run2')
    lines = filesystem.readlines(filename)
    failed_first_run_specs.each_with_object([]) do |failure, memo|
      puts failure if logging
      memo << get_rb_file_name(failure) if passed_on_second_run?(lines, failure)
    end
  end

  def self.passed_on_second_run?(lines, failure)
    lines.count { |line| line =~ /#{Regexp.quote(failure)}.*passed/ }.positive?
  end

  RUBY_FILE_SUFFIX = '.rb'

  def self.get_rb_file_name(name)
    name[0..(name.index(RUBY_FILE_SUFFIX) + RUBY_FILE_SUFFIX.length - 1)]
  end

  def self.rerun_failing_tests(results_files_wildcard = './spec/examples-*.txt',
                               default_result_file = './spec/examples.txt',
                               first_run_result_file = './spec/examples.txt.run1',
                               second_run_result_file = './spec/examples.txt.run2',
                               temp_result_file = './spec/examples-2.txt',
                               rspec_command = 'bundle exec rspec --only-failures',
                               issue_creator = CreateIntermittentFailIssue,
                               reporter = ReportIntermittentFails)
    FileUtils.rm Dir.glob(results_files_wildcard) # this was to remove parallel runs
    FileUtils.cp(default_result_file, temp_result_file) # because TEST_ENV_NUMBER default to 2

    ENV['TEST_ENV_NUMBER'] = '2' # just in case this ever changes in future
    output = `#{rspec_command}` # so here we are relying on rspec config
    puts '------------------------'
    puts output
    puts '------------------------'
    original_exit_status = $CHILD_STATUS.exitstatus
    puts "original exit status was: #{original_exit_status}"

    FileUtils.mv(temp_result_file, second_run_result_file)

    # assume that ./spec/examples.txt.run1 is available from previous reassemble step
    failed_first_run_specs = `grep "| failed" #{first_run_result_file} | cut -d" " -f1`.split("\n")
    puts "\n#{failed_first_run_specs.count} first run failures\n"

    fails = reporter.list_intermittent_fails(failed_first_run_specs, logging: true, filesystem: File, filename: second_run_result_file)

    repo_name_with_owner = ENV['REPO_NAME_WITH_OWNER'] || ENV['TRAVIS_REPO_SLUG']
    default_build_url = "https://travis-ci.org/#{repo_name_with_owner}/builds/#{ENV['TRAVIS_BUILD_ID']}"
    build_commit = ENV['CIRCLE_SHA1'] || ENV['GIT_COMMIT'] || ENV['TRAVIS_COMMIT'] || `git rev-parse HEAD`.chomp
    build_branch = ENV['CIRCLE_BRANCH'] || ENV['GIT_BRANCH'] || ENV['TRAVIS_BRANCH'] || `git rev-parse --abbrev-ref HEAD`.chomp
    build_url    = ENV['BUILD_URL'] || ENV['TRAVIS_JOB_WEB_URL'] || default_build_url
    build_node   = ENV['CIRCLE_NODE_INDEX'] || 'N/A'

    body = "Build: #{build_url}\nCommit: #{build_commit}\nBranch: #{build_branch}\n Container: #{build_node}"

    puts "\nGithub Issue body info:\n #{body}\n\n"
    puts "Submitting #{fails.count} intermittent fails\n"
    fails.each do |fail|
      puts fail
      issue_creator.with(title: "Intermittent Fail: #{fail}", body: body, branch: build_branch)
    end

    exit(original_exit_status)

    #  the above ruby code replaces the following bash/rake mix
    # rm ./spec/examples-*.txt
    # cp ./spec/examples.txt ./spec/examples-2.txt # because TEST_ENV_NUMBER default to 2
    # TEST_ENV_NUMBER=2 RAILS_ENV=test bundle exec rspec --only-failures
    # test_exit_code=$?
    # mv ./spec/examples-2.txt ./spec/examples.txt.run2
    # # this creates a github issue for anything that failed on the first run and passed on the second
    # # from https://gocardless.com/blog/track-flaky-specs-automatically/ (move into a rake task?)
    # grep "| failed" ./spec/examples.txt.run1 | cut -d" " -f1 \
    #   | xargs -I{} grep -F {} ./spec/examples.txt.run2 | grep "| passed" | cut -d"[" -f1 | uniq \
    #   | xargs -I{} bundle exec rake github:issues:create["Intermittent fail: {}","Build: $BUILD_URL"]
    # exit "$test_exit_code"
  end
end
