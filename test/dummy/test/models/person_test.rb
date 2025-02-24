require_relative "../test_helper"

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = people(:jan_tore)
  end

  def test_adds_description_with_concern_inclusion
    assert Person.included_modules.include?(Descripto::Associated)

    assert Person::Description::Types.all.include?("interest")

    assert @person.respond_to?(:interests)
  end

  def test_can_add_has_many_association
    association_class = @person._reflections[:interests].association_class
    assert_equal association_class, ActiveRecord::Associations::HasManyThroughAssociation
  end

  def test_can_add_has_one_association
    association_class = @person._reflections[:nationality].association_class
    assert_equal association_class, ActiveRecord::Associations::HasOneThroughAssociation
  end

  def test_people_can_have_descriptions
    assert @person.interests.present?
  end

  def test_people_can_have_description
    assert @person.nationality.present?
  end

  def test_description_can_be_added
    interest = Descripto::Description.create(
      name: "Tennis",
      name_key: "tennis",
      description_type: "interest"
    )

    @person.interests << interest
    assert @person.reload.interests.include?(interest)
  end

  def test_descriptions_can_be_set_with_ids
    interest = Descripto::Description.create(
      name: "Music",
      name_key: "music",
      description_type: "interest"
    )

    @person.interest_ids = @person.interest_ids + [interest.id]
    @person.save
    assert @person.reload.interests.include?(interest)
  end

  def test_has_one_description_can_be_set_with_id
    nationality = Descripto::Description.create(
      name: "French",
      name_key: "french",
      description_type: "nationality"
    )

    @person.nationality_id = nationality.id
    @person.save
    assert @person.reload.nationality = nationality
  end
end
