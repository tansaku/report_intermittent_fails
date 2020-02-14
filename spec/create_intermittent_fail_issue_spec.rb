# frozen_string_literal: true

require 'spec_helper'
require 'report_intermittent_fails'

RSpec.describe ReportIntermittentFails::CreateIntermittentFailIssue do
  let(:client) { spy :octokit_client }
  let(:title) { './spec/models/quote/quote_spec.rb[1:1:2]' }
  let(:repo_name_with_owner) { 'AgileVentures/LocalSupport' }
  let(:search_issues_query) { "repo:#{repo_name_with_owner} \"#{title}\"+in:title" }

  subject(:create_intermittent_fail_issue) do
    described_class.with(title: title,
                         body: 'body',
                         branch: branch,
                         client: client,
                         config: config)
  end

  let(:config) { ReportIntermittentFails::Config }
  let(:logger) { Logger.new(STDOUT, level: :warn) }

  before do
    allow(config).to receive(:logger).and_return logger
    allow(config).to receive(:repo_name_with_owner).and_return repo_name_with_owner
    allow(config).to receive(:main_branch).and_return 'master'
    allow(client).to receive(:search_issues).with(search_issues_query).and_return(result)
  end

  describe '.with' do
    context 'no existing issue of same title' do
      let(:result) { double :results, total_count: 0 }

      context 'on master branch' do
        let(:branch) { 'master' }
        it 'creates new issue and leaves it open' do
          create_intermittent_fail_issue
          expect(client).to have_received :create_issue
          expect(client).not_to have_received :close_issue
        end
      end

      context 'on non-master branch' do
        let(:branch) { 'non-master' }
        it 'creates issue but closes it' do
          create_intermittent_fail_issue
          expect(client).to have_received :create_issue
          expect(client).to have_received :close_issue
        end
      end
    end

    context 'an existing issue of same title' do
      let(:item) { double :item, number: 1234 }
      let(:result) { double :results, total_count: 1, items: [item] }

      subject(:create_intermittent_fail_issue) do
        described_class.with(title: title,
                             body: 'body',
                             branch: branch,
                             client: client)
      end

      context 'on master branch' do
        let(:branch) { 'master' }
        it 'adds comment ' do
          create_intermittent_fail_issue
          expect(client).to have_received :add_comment
        end

        it 'reopens issue' do
          create_intermittent_fail_issue
          expect(client).to have_received :reopen_issue
        end
      end

      context 'on non-master branch' do
        let(:branch) { 'non-master' }

        it 'adds comment if non-master branch specified' do
          create_intermittent_fail_issue
          expect(client).to have_received :add_comment
        end

        it 'does not reopen issue if non-master branch specified' do
          create_intermittent_fail_issue
          expect(client).not_to have_received :reopen_issue
        end
      end
    end
  end
end
