require_relative "../test_helper"

class CompanyTest < ActiveSupport::TestCase
  setup do
    @company = companies(:acme_corp)
  end

  def test_includes_descripto_associated_concern
    assert Company.included_modules.include?(Descripto::Associated)
    assert @company.respond_to?(:nationality)
    assert @company.respond_to?(:gender)
  end

  def test_can_set_two_has_one_descriptives_at_same_time
    german_nationality = descripto_descriptions(:german)
    male_gender = descripto_descriptions(:male)

    # This is the key test - setting two has_one descriptives in the same transaction
    @company.nationality = german_nationality
    @company.gender = male_gender
    @company.save

    # Both should be set correctly
    @company.reload
    assert_equal german_nationality, @company.nationality
    assert_equal male_gender, @company.gender
  end
end
