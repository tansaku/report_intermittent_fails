# frozen_string_literal: true

require 'octokit'

module ReportIntermittentFails
  # some extra methods to work with github client
  class Github
    ACCESS_TOKEN = ENV['GITHUB_ACCESS_TOKEN']
    CLIENT = Octokit::Client.new(access_token: ACCESS_TOKEN)

    # make sure we have the necessary settings set up
    def self.validate_settings
      raise "Please set ENV['GITHUB_ACCESS_TOKEN'] variable" unless ACCESS_TOKEN
      # raise "Please set ENV['REPO_NAME_WITH_OWNER'] variable." unless Config.repo_name_with_owner # Probably not needed
    end

    # search issues by title
    def self.search_issues_by_title(title, client: octokit_client)
      validate_settings

      query = "repo:#{Config.repo_name_with_owner} \"#{title}\"+in:title"
      client.search_issues(query)
    end

    # check if an issue with the passed in title exists
    def self.issue_exists?(title, issues = nil, client: octokit_client)
      issues = Github.search_issues_by_title(title, client: client) unless issues

      issues.total_count.zero? != true
    end

    # expose octokit
    def self.octokit_client
      ReportIntermittentFails::Github::CLIENT
    end
  end
end