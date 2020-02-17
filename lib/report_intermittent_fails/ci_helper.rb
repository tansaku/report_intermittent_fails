# frozen_string_literal: true

# CI help
module CiHelper
  # :nocov:
  # This should tell if we're running on a CI.
  def self.running_on_ci?
    CiHelper.running_on_travis? || CiHelper.running_on_circleci? || CiHelper.running_on_jenkins?
  end

  # This should tell if we're running on CircleCI.
  def self.running_on_circleci?
    ENV['CIRCLECI']
  end

  # This should tell if we're running on Jenkins.
  # Jenkins has no particular CI env variable,
  # so using BUILD_NUMBER, which is always present.
  def self.running_on_jenkins?
    ENV['BUILD_NUMBER']
  end

  # This should tell if we're running on Travis.
  def self.running_on_travis?
    ENV['TRAVIS']
  end

  # TRAVIS_BRANCH:
  #   for push builds, or builds not triggered by a pull request, this is the name of the branch.
  #   for builds triggered by a pull request this is the name of the branch targeted by the pull request.
  #   for builds triggered by a tag, this is the same as the name of the tag (TRAVIS_TAG).
  # TRAVIS_PULL_REQUEST_BRANCH:
  #   if the current job is a pull request, the name of the branch from which the PR originated.
  #   if the current job is a push build, this variable is empty ("").
  def self.travis_branch
    if ENV['TRAVIS_PULL_REQUEST_BRANCH'] && ENV['TRAVIS_PULL_REQUEST_BRANCH'] != ''
      ENV['TRAVIS_PULL_REQUEST_BRANCH']
    else
      ENV['TRAVIS_BRANCH']
    end
  end
  # :nocov:
end
