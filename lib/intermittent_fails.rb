# frozen_string_literal: true

def list_intermittent_fails(failed_first_run_specs, logging: false, filesystem: File)
  lines = filesystem.readlines('./spec/examples.txt.run2')
  failed_first_run_specs.each_with_object([]) do |failure, memo|
    puts failure if logging
    memo << get_rb_file_name(failure) if passed_on_second_run?(lines, failure)
  end
end

def passed_on_second_run?(lines, failure)
  lines.count { |line| line =~ /#{Regexp.quote(failure)}.*passed/ }.positive?
end

RUBY_FILE_SUFFIX = '.rb'

def get_rb_file_name(name)
  name[0..(name.index(RUBY_FILE_SUFFIX) + RUBY_FILE_SUFFIX.length - 1)]
end
