# frozen_string_literal: true

require 'fileutils'

# just holding some methods to be used in rake tasks
# do some CI already provide a similar function?
module ReportIntermittentFails
  def self.reassemble_spec_examples(results_files_wildcard = './spec/examples-*.txt',
                                    default_result_file = './spec/examples.txt',
                                    first_run_result_file = './spec/examples.txt.run1')
    # can't get this little bash script to work on jenkins, but works fine on local machine
    # sh '''array=( ./spec/examples-*.txt )
    # { cat ${array[@]:0:1}; grep -hv "^example_id\|^--------" ${array[@]:1}; } > ./spec/examples.txt'''
    # so using below ruby instead

    files = Dir[results_files_wildcard].sort
    file_contents = files.map { |f| File.readlines(f) }

    unless file_contents.empty?
      File.open(default_result_file, 'w') do |output_file|
        output_file.puts file_contents[0][0..1] # header row
        file_contents.each do |content|
          output_file.puts content[2..-1] # body without header
        end
      end
    end
    FileUtils.cp(default_result_file, first_run_result_file)

    # have tested by adding the following to the install dependencies stage on jenkins
    # echo -e "example_id\n-------\nline1" > ./spec/examples-.txt
    # echo -e "example_id\n-------\nline2" > ./spec/examples-1.txt
    # echo -e "example_id\n-------\nline3" > ./spec/examples-2.txt
    # bundle exec rails reassemble_spec_examples
    # more ./spec/examples.txt
  end
end
