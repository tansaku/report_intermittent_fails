# frozen_string_literal: true

require 'octokit'

REPO_NAME_WITH_OWNER = ENV['REPO_NAME_WITH_OWNER']
# e.g. agileventures/localsupport
CLIENT = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

# creates an issue on github for an intermittent failing test
class CreateIntermittentFailIssue
  def self.with(title:, body:, branch:, client: CLIENT)
    new(title, body, branch, client).send(:create_intermittent_fail_spec_issue)
  end

  private

  attr_reader :title, :body, :branch, :client
  attr_accessor :results

  def initialize(title, body, branch, client)
    @title = title
    @body = body
    @branch = branch
    @client = client
  end

  def create_intermittent_fail_spec_issue
    self.results = client.search_issues("\"#{title}\"+in:title")

    results.total_count.zero? ? handle_new_intermittent_fail : handle_existing_intermittent_fail
  end

  def handle_new_intermittent_fail
    return unless master?(branch)

    client.create_issue(REPO_NAME_WITH_OWNER, title, body, labels: [':dolphin: intermittent_fail spec'])
  end

  def handle_existing_intermittent_fail
    number = results.items[0].number
    client.add_comment(REPO_NAME_WITH_OWNER, number, "#{title}\n\n#{body}")
    client.reopen_issue(REPO_NAME_WITH_OWNER, number) if master?(branch)
  end

  def master?(branch)
    branch == 'master'
  end
end
