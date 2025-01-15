# frozen_string_literal: true

require "test_helper"

class TestDescripto < Minitest::Test
  def test_should_have_version_number
    refute_nil ::Descripto::VERSION
  end

  def test_should_have_model_parent_class
    assert_equal "ApplicationRecord", ::Descripto.model_parent_class

    ::Descripto.model_parent_class = "ActiveRecord::Base"
    assert_equal "ActiveRecord::Base", ::Descripto.model_parent_class
  end

  def test_should_have_descriptions_table_name
    assert_equal "descriptions", ::Descripto.descriptions_table_name

    ::Descripto.descriptions_table_name = "descriptions_table"
    assert_equal "descriptions_table", ::Descripto.descriptions_table_name
  end

  def test_should_have_descriptives_table_name
    assert_equal "descriptives", ::Descripto.descriptives_table_name

    ::Descripto.descriptives_table_name = "descriptives_table"
    assert_equal "descriptives_table", ::Descripto.descriptives_table_name
  end
end
