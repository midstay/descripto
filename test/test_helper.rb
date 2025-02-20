# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "./dummy/config/environment"

$LOAD_PATH.unshift File.expand_path("../lib", __dir__)
require "descripto"

require "minitest/autorun"
require "rails/test_help"
