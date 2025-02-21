# frozen_string_literal: true

require "test_helper"

class TestDescripto < ActiveSupport::TestCase
  def test_it_has_a_version_number
    refute_nil ::Descripto::VERSION
  end
end
