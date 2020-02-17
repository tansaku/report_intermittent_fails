# frozen_string_literal: true

require 'fileutils'
require_relative 'config'

# Assemble multiple rspec result files into one single file.
module ReportIntermittentFails
  # Do some CI already provide a similar function?
  def self.reassemble_spec_examples(results_files_wildcard = Config.results_files_wildcard,
                                    default_result_file = Config.default_result_file,
                                    first_run_result_file = Config.first_run_result_file)
    # can't get this little bash script to work on jenkins, but works fine on local machine
    # sh '''array=( ./spec/examples-*.txt )
    # { cat ${array[@]:0:1}; grep -hv "^example_id\|^--------" ${array[@]:1}; } > ./spec/examples.txt'''
    # so using below ruby instead
    file_contents = file_contents_nested_array(results_files_wildcard)

    unless file_contents.empty?
      File.open(default_result_file, 'w') do |output_file|
        output_file.puts file_contents[0][0..1] # header row
        file_contents.each do |content|
          output_file.puts content[2..-1] # body without header
        end
      end
    end

    #            examples.txt       -> examples.txt.run1
    FileUtils.cp(default_result_file, first_run_result_file)

    # have tested by adding the following to the install dependencies stage on jenkins
    # echo -e "example_id\n-------\nline1" > ./spec/examples-.txt
    # echo -e "example_id\n-------\nline2" > ./spec/examples-1.txt
    # echo -e "example_id\n-------\nline3" > ./spec/examples-2.txt
    # bundle exec rails reassemble_spec_examples
    # more ./spec/examples.txt
  end

  def self.file_contents_nested_array(results_files_wildcard)
    files = Dir[results_files_wildcard].sort
    files.map { |f| File.readlines(f) }
  end
end
