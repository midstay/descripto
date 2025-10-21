# frozen_string_literal: true

require_relative "../../test_helper"

module Venues
  class EventSpaceTest < ActiveSupport::TestCase
    test "should scoped the model correctly" do
      assert_equal Venues::EventSpace.description_type_for(:setups), "venues_event_space_setup"
    end
  end
end
