# frozen_string_literal: true

require 'octokit'
require_relative 'config'

module ReportIntermittentFails
  # Extra methods to work with the github client
  class Github
    # make sure we have the necessary settings set up
    def self.validate(config)
      raise "Please set ENV['GITHUB_ACCESS_TOKEN'] variable" unless config.access_token
      raise "Please set ENV['REPO_NAME_WITH_OWNER'] variable" unless config.repo_name_with_owner
    end

    # search issues by title
    def self.search_issues_by_title(title, client: octokit_client, config: ReportIntermittentFails::Config)
      validate(config)

      query = "repo:#{config.repo_name_with_owner} \"#{title}\"+in:title"
      client.search_issues(query)
    end

    # check if an issue with the passed in title exists
    def self.issue_exists?(title, issues = nil, client: octokit_client, config: ReportIntermittentFails::Config)
      issues ||= Github.search_issues_by_title(title, client: client, config: config)

      issues.total_count == 1
    end

    # check if an issue with the passed in title was commented in the last minute
    def self.issue_was_commented_in_the_last_minute?(title, issues = nil, client: octokit_client, config: ReportIntermittentFails::Config)
      issues ||= Github.search_issues_by_title(title, client: client, config: config)

      issue_number = issues.items.first.number
      comments = client.issue_comments(config.repo_name_with_owner, issue_number) # this can become huge! is there a better way?
      comment = comments.last

      comment.created_at.utc < Time.now.utc - 60
    end

    # expose octokit
    def self.octokit_client(config = ReportIntermittentFails::Config)
      validate(config)

      Octokit::Client.new(access_token: config.access_token)
    end
  end
end
