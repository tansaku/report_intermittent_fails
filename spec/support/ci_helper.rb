# CI help
module CiHelper
  # CircleCI publishes ENV[CI].
  # This should tell if we're running on CI.
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
end
