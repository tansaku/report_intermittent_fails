# frozen_string_literal: true

require 'rubocop/rake_task'
require 'rspec/core/rake_task'
require_relative 'lib/report_intermittent_fails/version'
require_relative 'lib/report_intermittent_fails/config'
require_relative 'lib/report_intermittent_fails/reassemble_spec_examples'
require_relative 'lib/report_intermittent_fails/rerun_failing_tests'

RuboCop::RakeTask.new(:rubocop) do |t|
  t.options = ['--display-cop-names', '-a']
end

RSpec::Core::RakeTask.new(:spec)

task default: %i[rubocop spec]

# Following tasks are used only during an end-to-end test on the main repo.
# TODO: dry up
namespace :report do
  desc 'rerun_failing_tests'
  task :rerun do
    ReportIntermittentFails.rerun_failing_tests
  end
  desc 'reassemble_spec_examples'
  task :reassemble do
    ReportIntermittentFails.reassemble_spec_examples
  end
  desc 'check endtoend test result'
  task :endtoend do
    ReportIntermittentFails.endtoend_check
  end
end
task test_report_fails: ['report:rerun']
task test_report_fails: ['report:reassemble']
task test_report_fails: ['report:endtoend']
