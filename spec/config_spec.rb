# frozen_string_literal: true

require 'report_intermittent_fails/config'

describe ReportIntermittentFails::Config do
  subject(:config) { described_class }

  it 'has logger set' do
    expect(config.logger).not_to be_nil
  end

  it 'has results_files_wildcard set' do
    expect(config.results_files_wildcard).to eq './spec/examples-*.txt'
  end

  it 'has default_result_file set' do
    expect(config.default_result_file).to eq './spec/examples.txt'
  end

  it 'has first_run_result_file set' do
    expect(config.first_run_result_file).to eq './spec/examples.txt.run1'
  end

  it 'has second_run_result_file set' do
    expect(config.second_run_result_file).to eq './spec/examples.txt.run2'
  end

  it 'has temp_result_file set' do
    expect(config.temp_result_file).to eq './spec/examples-2.txt'
  end

  it 'has rspec_command set' do
    expect(config.rspec_command).to eq 'bundle exec rspec --only-failures'
  end

  it 'has repo_name_with_owner set' do
    expect(config.repo_name_with_owner).to eq nil
  end

  it 'has main_branch set' do
    expect(config.main_branch).to eq 'master'
  end
end
