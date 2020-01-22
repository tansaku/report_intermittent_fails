# frozen_string_literal: true

require 'spec_helper'
require 'create_intermittent_fail_issue'

RSpec.describe CreateIntermittentFailIssue do
  let(:client) { spy :octokit_client }
  let(:title) { './spec/models/quote/quote_spec.rb[1:1:2]' }

  describe '.with' do
    context 'no existing issue of same title' do
      let(:empty_result) { double :results, total_count: 0 }

      it 'creates new issue if master branch specified' do
        expect(client).to receive(:search_issues).with("\"#{title}\"+in:title").and_return(empty_result)
        described_class.with(title: title, body: 'body', branch: 'master', client: client)
        expect(client).to have_received :create_issue
      end

      it 'creates no new issue if non-master branch specified' do
        expect(client).to receive(:search_issues).with("\"#{title}\"+in:title").and_return(empty_result)
        described_class.with(title: title, body: 'body', branch: 'non-master', client: client)
        expect(client).not_to have_received :create_issue
      end
    end

    context 'an existing issue of same title' do
      let(:item) { double :item, number: 1234 }
      let(:result) { double :results, total_count: 1, items: [item] }
      before { expect(client).to receive(:search_issues).with("\"#{title}\"+in:title").and_return(result) }

      it 'adds comment if master branch specified' do
        described_class.with(title: title, body: 'body', branch: 'master', client: client)
        expect(client).to have_received :add_comment
      end

      it 'adds comment if non-master branch specified' do
        described_class.with(title: title, body: 'body', branch: 'non-master', client: client)
        expect(client).to have_received :add_comment
      end

      it 'reopens issue if master branch specified' do
        described_class.with(title: title, body: 'body', branch: 'master', client: client)
        expect(client).to have_received :reopen_issue
      end

      it 'does not reopen issue if non-master branch specified' do
        described_class.with(title: title, body: 'body', branch: 'non-master', client: client)
        expect(client).not_to have_received :reopen_issue
      end
    end
  end
end
