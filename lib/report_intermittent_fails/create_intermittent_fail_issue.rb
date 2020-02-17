# frozen_string_literal: true

require_relative 'github'
require_relative 'config'

module ReportIntermittentFails
  # Creates an issue on github for an intermittent failing test
  # e.g. repo_name_with_owner: 'agileventures/localsupport'
  class CreateIntermittentFailIssue
    def self.with(title:, body:, branch:, client: Github.octokit_client, config: ReportIntermittentFails::Config)
      new(title, body, branch, client, config).send(:create_intermittent_fail_spec_issue)
    end

    private

    attr_reader :title, :body, :branch, :client, :config
    attr_accessor :issues

    def initialize(title, body, branch, client, config)
      @title = title
      @body = body
      @branch = branch
      @client = client
      @config = config
    end

    def create_intermittent_fail_spec_issue
      self.issues = Github.search_issues_by_title(title, client: client, config: config)
      if Github.issue_exists?(title, issues, client: client, config: config)
        handle_existing_intermittent_fail
      else
        handle_new_intermittent_fail
      end
    end

    def handle_new_intermittent_fail
      issue = client.create_issue(config.repo_name_with_owner,
                                  title,
                                  body,
                                  labels: [':dolphin: intermittent_fail spec'])
      client.close_issue(config.repo_name_with_owner, issue.number) unless master?(branch)
    end

    # rubocop:disable Metrics/AbcSize
    def handle_existing_intermittent_fail
      number = issues.items[0].number
      client.add_comment(config.repo_name_with_owner, number, "#{title}\n\n#{body}")
      client.reopen_issue(config.repo_name_with_owner, number) if master?(branch)
    end
    # rubocop:enable Metrics/AbcSize

    def master?(branch)
      branch == config.main_branch
    end
  end
end
