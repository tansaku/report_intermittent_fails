# frozen_string_literal: true

require 'spec_helper'
require 'report_intermittent_fails'

describe ReportIntermittentFails do
  it 'has a version number' do
    expect(ReportIntermittentFails::VERSION).not_to be nil
  end

  describe '#list_intermittent_fails' do
    context 'no file contents' do
      let(:filesystem) { double File, readlines: [] }

      it 'returns empty array' do
        expect(ReportIntermittentFails.list_intermittent_fails([], logging: false, filesystem: filesystem)).to eq([])
      end
    end

    context 'file present' do
      let(:filesystem) { double File, readlines: [] }
      let(:first_run_failed_specs) do
        [
          './spec/controllers/application_controller_spec.rb[1:1]'
        ]
      end
      let(:confirmed_intermittent_failed_specs) do
        [
          './spec/controllers/application_controller_spec.rb'
        ]
      end

      it 'returns array of intermittent fails' do
        # this assumes that we have a file 'fixtures/examples.txt' that contains 'passed'
        # for 'application_controller_spec.rb[1:1]'
        confirmed_intermittent = ReportIntermittentFails.list_intermittent_fails(first_run_failed_specs,
                                                                                 logging: false,
                                                                                 filename: 'fixtures/examples.txt')
        expect(confirmed_intermittent).to eq(confirmed_intermittent_failed_specs)
      end

      it 'does not return when failure is consistent' do
        # this assumes that we have a file 'fixtures/examples.txt' that contains 'failed'
        # for 'application_controller_spec.rb[1:1]'
        confirmed_intermittent = ReportIntermittentFails.list_intermittent_fails(first_run_failed_specs,
                                                                                 logging: false,
                                                                                 filename: 'fixtures/examples2.txt')
        expect(confirmed_intermittent).to eq([])
      end
    end
  end

  it '#passed_on_second_run?' do
    expect(ReportIntermittentFails.passed_on_second_run?([], 'fail')).to eq(false)
  end

  it '#get_rb_file_name' do
    expect(ReportIntermittentFails.get_rb_file_name('ruby.rb[1:1]')).to eq('ruby.rb')
  end

  let(:results_files_wildcard) { './fixtures/examples-*.txt.dummy' }
  let(:default_result_file) { './fixtures/default_result_file.txt' }
  let(:first_run_result_file) { './fixtures/examples.txt.run1' }
  let(:second_run_result_file) { './fixtures/examples.txt.run2' }
  let(:temp_result_file) { './fixtures/examples.txt.run2.dummy' }
  let(:rspec_command) { 'pwd' }
  let(:issue_creator) { double ReportIntermittentFails::CreateIntermittentFailIssue, with: '' }
  let(:reporter) { double ReportIntermittentFails, list_intermittent_fails: ['I am a fail'] }
  let(:config) { ReportIntermittentFails::Config }
  let(:logger) { Logger.new(STDOUT, level: :warn) }

  before do
    allow(config).to receive(:logger).and_return logger
    allow(config).to receive(:results_files_wildcard).and_return results_files_wildcard
    allow(config).to receive(:default_result_file).and_return default_result_file
    allow(config).to receive(:first_run_result_file).and_return first_run_result_file
    allow(config).to receive(:second_run_result_file).and_return second_run_result_file
    allow(config).to receive(:temp_result_file).and_return temp_result_file
    allow(config).to receive(:rspec_command).and_return rspec_command
  end

  # rubocop:disable Style/MultilineBlockChain
  it '#rerun_failing_tests' do
    expect do
      ReportIntermittentFails.rerun_failing_tests(issue_creator,
                                                  reporter)
    end.to raise_error(SystemExit) do |error|
      expect(error.status).to eq(0)
    end
    # identical = FileUtils.identical?(first_run_expected_result_file, first_run_result_file)
    # expect(identical).to be true
    # TODO need to stub CreateIntermittentFailIssue
    # use logger, handle exit
  end
  # rubocop:enable Style/MultilineBlockChain
end
