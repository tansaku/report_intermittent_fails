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
end
