# frozen_string_literal: true

require 'fileutils'
require '.lib/create_intermittent_fail_issue'
require './lib/report_intermittent_fails'

DEFAULT_BUILD_URL = "https://app.circleci.com/jobs/github/agileventures/localsupport/#{ENV['CIRCLE_BUILD_NUM']}/tests"

task :rerun_failing_tests do
  FileUtils.rm Dir.glob('./spec/examples-*.txt')
  FileUtils.cp('./spec/examples.txt', './spec/examples-2.txt') # because TEST_ENV_NUMBER default to 2

  ENV['TEST_ENV_NUMBER'] = '2' # just in case this ever changes in future
  output = `bundle exec rspec --only-failures`
  puts '------------------------'
  puts output
  puts '------------------------'
  original_exit_status = $CHILD_STATUS.exitstatus
  puts "original exit status was: #{original_exit_status}"

  FileUtils.mv('./spec/examples-2.txt', './spec/examples.txt.run2')

  failed_first_run_specs = `grep "| failed" ./spec/examples.txt.run1 | cut -d" " -f1`.split("\n")
  puts "\n#{failed_first_run_specs.count} first run failures\n"

  flappies = ReportIntermittentFails.list_intermittent_fails(failed_first_run_specs, logging: true)

  build_commit = ENV['CIRCLE_SHA1'] || ENV['GIT_COMMIT']
  build_branch = ENV['CIRCLE_BRANCH'] || ENV['GIT_BRANCH']
  build_url    = ENV['BUILD_URL'] || DEFAULT_BUILD_URL
  build_node   = ENV['CIRCLE_NODE_INDEX'] || 'N/A'

  body = "Build: #{build_url}\nCommit: #{build_commit}\nBranch: #{build_branch}\n Container: #{build_node}"

  puts "\nGithub Issue body info:\n #{body}\n\n"
  puts "Submitting #{flappies.count} flappies\n"
  fails.each do |fail|
    puts fail
    CreateIntermittentFailIssue.with(title: "Intermittent Fail: #{fail}", body: body, branch: build_branch)
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
