# frozen_string_literal: true

require "test_helper"

class TestDescripto < ActiveSupport::TestCase
  test "should have version number" do
    refute_nil Descripto::VERSION
  end

  test "should have parent model class" do
    refute_nil Descripto.parent_model_class
  end

  test "should be able to set parent model class" do
    Descripto.parent_model_class = "ActiveRecord::Base"
    assert_equal "ActiveRecord::Base", Descripto.parent_model_class
  end
end
