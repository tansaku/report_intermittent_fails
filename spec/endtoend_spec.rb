# frozen_string_literal: true

require 'spec_helper'
require 'report_intermittent_fails'

RSpec.describe 'End to end' do
  if CiHelper.running_on_ci? # run this only on CI
    # assuming ENV variable for the GITHUB_ACCESS_TOKEN and REPO_NAME_WITH_OWNER is set in the CI tool!
    let(:client) { Github.octokit_client }
    let(:repo_name_with_owner) { ReportIntermittentFails::Config.repo_name_with_owner }
    let(:intermittent_fail_indicator_file) { './tmp/failed_on_first_run.txt' }
    let(:end_to_end_indicator_file) { './tmp/end_to_end.txt' }
    let(:title) { './spec/endtoend_spec.rb' }

    let(:search_issues_query) { "repo:#{repo_name_with_owner} \"#{title}\"+in:title" }

    before do
      Dir.mkdir('tmp') unless File.exist?('tmp')
    end

    context 'randomly failing' do
      it 'checks' do
        if File.exist?(end_to_end_indicator_file)
          # this is the third run, we need to check if the issue was created and left open
          # delete the indicator file
          File.delete(end_to_end_indicator_file)

          expect(Github.issue_exists?(title, client: client)).to eq true
          expect(Github.issue_was_commented_in_the_last_minute?(title, client: client)).to eq true
        elsif File.exist?(intermittent_fail_indicator_file)
          # this is the second run

          # delete the indicator file
          File.delete(intermittent_fail_indicator_file)

          # when the file exists, it means the first run has happened,
          # it is impossible to check if the issue was created at this point,
          # since it will be created only after this spec finishes
          # so we leave this for a third pass, which needs to be invoked by the CI script,
          # then a check for the presence of the issue can be done
          # rake report:endtoend

          # here we only set up an indicator for the third run:
          File.write(intermittent_fail_indicator_file, search_issues_query)
        else
          # when the file is not there, it means this test is being run for the first time,
          # so generate the file and fail - to simulate a random fail, the subsequent run would then succeed
          File.write(intermittent_fail_indicator_file, 'Fail')
          expect('random').to eq 'fail'
          # after this spec finishes, an issue should be opened
        end
      end
    end
  end
end
