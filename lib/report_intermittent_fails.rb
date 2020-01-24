# frozen_string_literal: true

require 'report_intermittent_fails/version'

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
end
