# Report Intermittent Fails
Open Github Issues for intermittently failing tests.  Inspired by [GoCardless](https://gocardless.com/blog/track-flaky-specs-automatically/)

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'report_intermittent_fails'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install report_intermittent_fails

## Usage

TODO: work out how this gets used ...

Relying on spec_helper.rb setting:

```
  config.example_status_persistence_file_path = "spec/examples.txt"
```

and env setting

```
REPO_NAME_WITH_OWNER=AgileVentures/LocalSupport
GITHUB_ACCESS_TOKEN=<token>
MAIN_BRANCH=develop
```

NOTE: do we need list of branches we can open new issues for?

```
$ bundle exec dotenv rake report_intermittent_fails:rerun_failing_tests
DEPRECATION WARNING: `secrets.secret_token` is deprecated in favor of `secret_key_base` and will be removed in Rails 6.0. (called from <top (required)> at /Users/tansaku/Documents/GitHub/AgileVentures/LocalSupport/config/environment.rb:5)
------------------------
Run options: include {:last_run_status=>"failed"}

All examples were filtered out

Randomized with seed 19009

Top 0 slowest examples (0 seconds, 0.0% of total time):

Finished in 0.1098 seconds (files took 6.91 seconds to load)
0 examples, 0 failures

Randomized with seed 19009

Coverage report generated for RSpec to /Users/tansaku/Documents/GitHub/AgileVentures/LocalSupport/coverage. 951 / 2077 LOC (45.79%) covered.
------------------------
original exit status was: 0

1 first run failures
./spec/controllers/application_controller_spec.rb[1:1]

Github Issue body info:
 Build: https://travis-ci.org/AgileVentures/LocalSupport/builds//tests
Commit: 9da70983f3f3bbfd1f1cac20b2e046f15cf566fd
Branch: list_intermittent_fails
 Container: N/A

Submitting 1 intermittent fails
./spec/controllers/application_controller_spec.rb
found 1 issues for repo:AgileVentures/LocalSupport "Intermittent Fail: ./spec/controllers/application_controller_spec.rb"+in:title
```

to run in CI the gem needs to be added and the takes run from the CI script, e.g. in .travis.yml

```
- bundle exec rake report_intermittent_fails:reassemble_spec_examples
- bundle exec rake report_intermittent_fails:rerun_failing_tests
```
even if you are not breaking the tests up to run in parallel `reassemble_spec_examples` is currently needed to put the test results in the correct file for processing by `rerun_failing_tests`

## TODO

* are there existing test reassembling tools that would be more reliable for us to use?

## Approach

So we have a couple of well tested objects to create issues and to analyze rspec logs.  We also have two rake tasks that are not covered in tests and involve running a chunk of stuff on the metal via backticks.

Guess next step is to maybe remove all the `puts` and move to a logger, but even more important than that would be to see all this working in travis for a complete round trip there ...

## Development

After checking out the repo, run `bin/setup` to install dependencies. Then, run `rake` to run the tests. You can also run `bin/console` for an interactive prompt that will allow you to experiment.

To install this gem onto your local machine, run `bundle exec rake install`. To release a new version, update the version number in `version.rb`, and then run `bundle exec rake release`, which will create a git tag for the version, push git commits and tags, and push the `.gem` file to [rubygems.org](https://rubygems.org).

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/tansaku/report_intermittent_fails. This project is intended to be a safe, welcoming space for collaboration, and contributors are expected to adhere to the [Contributor Covenant](http://contributor-covenant.org) code of conduct.

## Code of Conduct

Everyone interacting in the ReportIntermittentFails project’s codebases, issue trackers, chat rooms and mailing lists is expected to follow the [code of conduct](https://github.com/tansaku/report_intermittent_fails/blob/master/CODE_OF_CONDUCT.md).

## TODO

* [ ] usage instructions
* [ ] consistent approach for env vars
* [ ] more tests 
* [ ] gemification

## Related

* https://stackoverflow.com/questions/37114184/what-is-a-systematic-approach-to-debug-intermittently-failing-specs
* https://github.com/grosser/parallel_tests/issues/699#issuecomment-513827430
