# frozen_string_literal: true

require 'fileutils'

describe '.reassemble_spec_examples' do
  let(:results_files_wildcard) { './fixtures/examples-*.txt' }
  let(:default_result_file) { './fixtures/default_result_file.txt' }
  let(:first_run_result_file) { './fixtures/examples.txt.run1' }
  let(:first_run_expected_result_file) { './fixtures/examples.txt.run1.expected' }

  before do
    FileUtils.rm first_run_result_file if File.exist? first_run_result_file
  end

  it 'takes several test output files and merges them into one' do
    ReportIntermittentFails.reassemble_spec_examples(results_files_wildcard,
                                                     default_result_file,
                                                     first_run_result_file)

    expect(FileUtils).to be_identical(first_run_expected_result_file, first_run_result_file)
  end
end
