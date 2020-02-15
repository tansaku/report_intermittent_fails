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

# Following tasks are used for an end-to-end test.
desc 'rerun failing tests'
task :rerun do
  ReportIntermittentFails.rerun_failing_tests
end

desc 'reassemble spec examples'
task :reassemble do
  ReportIntermittentFails.reassemble_spec_examples
end

desc 'check endtoend test result'
task :endtoend do
  ReportIntermittentFails.run_endtoend_check
end

desc 'clean endtoend test files'
task :'endtoend-clean' do
  FileUtils.rm Dir.glob(ReportIntermittentFails::Config.results_files_wildcard), force: true
  FileUtils.rm ReportIntermittentFails::Config.default_result_file, force: true
  FileUtils.rm ReportIntermittentFails::Config.first_run_result_file, force: true
  FileUtils.rm ReportIntermittentFails::Config.second_run_result_file, force: true
  FileUtils.rm ReportIntermittentFails::Config.temp_result_file, force: true
  FileUtils.rm './tmp/failed_on_first_run.txt' , force: true
  FileUtils.rm './tmp/end_to_end.txt' , force: true
end
