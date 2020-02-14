# frozen_string_literal: true

require_relative 'github'

module ReportIntermittentFails
  # creates an issue on github for an intermittent failing test
  # e.g. repo_name_with_owner: 'agileventures/localsupport'
  class CreateIntermittentFailIssue
    def self.with(title:, body:, branch:, client: Github.octokit_client)
      new(title, body, branch, client).send(:create_intermittent_fail_spec_issue)
    end

    private

    attr_reader :title, :body, :branch, :client
    attr_accessor :issues

    def initialize(title, body, branch, client)
      @title = title
      @body = body
      @branch = branch
      @client = client
    end

    def create_intermittent_fail_spec_issue
      self.issues = Github.search_issues_by_title(title, client: client)
      Github.issue_exists?(title, issues, client: client) ? handle_existing_intermittent_fail : handle_new_intermittent_fail
    end

    def handle_new_intermittent_fail
      issue = client.create_issue(Config.repo_name_with_owner,
                                  title,
                                  body,
                                  labels: [':dolphin: intermittent_fail spec'])
      client.close_issue(Config.repo_name_with_owner, issue.number) unless master?(branch)
    end

    def handle_existing_intermittent_fail
      number = issues.items[0].number
      client.add_comment(Config.repo_name_with_owner, number, "#{title}\n\n#{body}")
      client.reopen_issue(Config.repo_name_with_owner, number) if master?(branch)
    end

    def master?(branch)
      branch == Config.main_branch
    end
  end
end
