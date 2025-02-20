# frozen_string_literal: true

ENV["RAILS_ENV"] ||= "test"
require_relative "../config/environment"

require "minitest/autorun"
require "rails/test_help"

class ActiveSupport::TestCase
  self.fixture_paths = [Rails.root.join("test/fixtures")]

  fixtures :all
end
