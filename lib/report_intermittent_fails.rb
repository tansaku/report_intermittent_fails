# frozen_string_literal: true

require 'report_intermittent_fails/version'
require 'report_intermittent_fails/config'
require 'report_intermittent_fails/ci_helper'
require 'report_intermittent_fails/reassemble_spec_examples'
require 'report_intermittent_fails/rerun_failing_tests'
require 'report_intermittent_fails/railtie' if defined?(Rails)
