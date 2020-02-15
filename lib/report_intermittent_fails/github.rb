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
    def self.issue_exists?(title,
                           issues = nil,
                           client: octokit_client,
                           config: ReportIntermittentFails::Config)
      issues ||= Github.search_issues_by_title(title, client: client, config: config)

      issues.total_count == 1
    end

    # check if an issue with the passed in title was commented recently
    # if so, attempt to delete the comment
    def self.issue_was_commented_recently?(title,
                                           issues = nil,
                                           minutes: 10,
                                           client: octokit_client,
                                           config: ReportIntermittentFails::Config)
      issues ||= Github.search_issues_by_title(title, client: client, config: config)

      issue_number = issues.items.first.number
      # this can become huge ~ is there a better way to get the last comment on the issue?
      comments = client.issue_comments(config.repo_name_with_owner, issue_number)
      comment = comments.last

      return false unless comment

      time = Time.now.utc - (60 * minutes)
      if comment.created_at.utc > time
        #delete the comment before returning
        client.delete_comment(config.repo_name_with_owner, comment.id)
        true
      else
        false
      end
    end

    # expose octokit
    def self.octokit_client(config = ReportIntermittentFails::Config)
      validate(config)

      Octokit::Client.new(access_token: config.access_token)
    end
  end
end
