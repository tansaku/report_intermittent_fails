
require 'fileutils'
require 'reassemble_spec_examples'
require 'rerun_failing_tests'
require 'rails'

module ReportIntermittentFails
  # binds rake tasks into Rails
  class Railtie < Rails::Railtie
    railtie_name :report_intermittent_fails
    rake_tasks do
      namespace :report_intermittent_fails do
        desc 'rerun_failing_tests'
        task rerun_failing_tests: :environment do
          ReportIntermittentFails.rerun_failing_tests
        end
        desc 'reassemble_spec_examples'
        task reassemble_spec_examples: :environment do
          ReportIntermittentFails.reassemble_spec_examples
        end
      end

      task report_intermittent_fails: ['report_intermittent_fails:rerun_failing_tests']
      task report_intermittent_fails: ['report_intermittent_fails:reassemble_spec_examples']
    end
  end
end
