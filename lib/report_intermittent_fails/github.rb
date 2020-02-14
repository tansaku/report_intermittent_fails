# frozen_string_literal: true

require 'octokit'

module ReportIntermittentFails
  # some extra methods to work with github client
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
      issues = Github.search_issues_by_title(title, client: client, config: config) unless issues

      issues.total_count.zero? != true
    end

    # expose octokit
    def self.octokit_client(config = ReportIntermittentFails::Config)
      validate(config)

      Octokit::Client.new(access_token: config.access_token)
    end
  end
end