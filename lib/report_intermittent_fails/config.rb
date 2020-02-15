# frozen_string_literal: true

require 'logger'

module ReportIntermittentFails
  # Settings
  # Idea: should be loaded from a file, perhaps: .report_intermittent_fails
  class Config
    def self.logger
      @logger ||= Logger.new(STDOUT, level: :info)
    end

    def self.results_files_wildcard
      './spec/examples-*.txt'
    end

    def self.default_result_file
      './spec/examples.txt'
    end

    def self.first_run_result_file
      './spec/examples.txt.run1'
    end

    def self.second_run_result_file
      './spec/examples.txt.run2'
    end

    def self.temp_result_file
      './spec/examples-2.txt'
    end

    def self.rspec_command
      'bundle exec rspec --only-failures'
    end

    def self.rspec_endtoend_command
      'bundle exec rspec spec/endtoend_spec.rb'
    end

    def self.repo_name_with_owner
      ENV['REPO_NAME_WITH_OWNER'] # Idea: can be read from .git/config
    end

    def self.issue_title_prefix
      "Intermittent fail: "
    end

    def self.issue_title_for(failure)
      "#{issue_title_prefix}#{failure}"
    end

    def self.access_token
      ENV['GITHUB_ACCESS_TOKEN']
    end

    def self.main_branch
      ENV['MAIN_BRANCH'] || 'master'
    end
  end
end
