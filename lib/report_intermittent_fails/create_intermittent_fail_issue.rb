# frozen_string_literal: true

require 'octokit'

module ReportIntermittentFails
  CLIENT = Octokit::Client.new(access_token: ENV['GITHUB_ACCESS_TOKEN'])

  # creates an issue on github for an intermittent failing test
  # e.g. repo_name_with_owner: 'agileventures/localsupport'
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
      # TODO: maybe should wig out if no REPO_NAME_WITH_OWNER
      # or just log everything?
      query = "repo:#{Config.repo_name_with_owner} \"#{title}\"+in:title"
      self.results = client.search_issues(query)
      # puts "found #{results.total_count} issues for #{query}"
      results.total_count.zero? ? handle_new_intermittent_fail : handle_existing_intermittent_fail
    end

    def handle_new_intermittent_fail
      return unless master?(branch)

      client.create_issue(Config.repo_name_with_owner, title, body, labels: [':dolphin: intermittent_fail spec'])
    end

    def handle_existing_intermittent_fail
      number = results.items[0].number
      client.add_comment(Config.repo_name_with_owner, number, "#{title}\n\n#{body}")
      client.reopen_issue(Config.repo_name_with_owner, number) if master?(branch)
    end

    def master?(branch)
      branch == Config.main_branch
    end
  end
end
