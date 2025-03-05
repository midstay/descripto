require_relative "../test_helper"

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = people(:jan_tore)
  end

  test "adds description with concern inclusion" do
    assert Person.included_modules.include?(Descripto::Associated)

    assert Person.descripto_descriptions[:types].include?(:interests)

    assert @person.respond_to?(:interests)
  end

  test "can add has_many_association" do
    association_class = @person._reflections[:interests].association_class
    assert_equal association_class, ActiveRecord::Associations::HasManyThroughAssociation
  end

  test "can add has_one_association" do
    association_class = @person._reflections[:nationality].association_class
    assert_equal association_class, ActiveRecord::Associations::HasOneThroughAssociation
  end

  test "people can have descriptions" do
    assert @person.interests.present?
  end

  def test_people_can_have_description
    assert @person.nationality.present?
  end

  test "description can be added" do
    interest = Descripto::Description.create(
      name: "Tennis",
      name_key: "tennis",
      description_type: "interest"
    )

    @person.interests << interest
    assert @person.reload.interests.include?(interest)
  end

  test "descriptions can be set with ids" do
    interest = Descripto::Description.create(
      name: "Music",
      name_key: "music",
      description_type: "interest"
    )

    @person.interest_ids = @person.interest_ids + [interest.id]
    @person.save
    assert @person.reload.interests.include?(interest)
  end

  test "has_one_description_can_be_set_with_id" do
    nationality = Descripto::Description.create(
      name: "French",
      name_key: "french",
      description_type: "nationality"
    )

    @person.nationality_id = nationality.id
    @person.save
    assert @person.reload.nationality = nationality
  end

  test "should scope description type if scoped" do
    interest_options = Person.descripto_descriptions[:options][:interests]
    assert interest_options[:scoped].blank?

    interests_description_type = Person.first.interests.first.description_type
    assert interests_description_type.exclude?("person")

    nationality_options = Person.descripto_descriptions[:options][:nationality]
    assert nationality_options[:scoped].eql?(true)

    nationality_description_type = Person.first.nationality.description_type
    assert nationality_description_type.include?("person")
  end

  test "should be able to create custom descriptions from string" do
    assert_difference "Descripto::Description.count", 1 do
      @person.custom_objectives = ["Learning"]
      @person.save
    end

    assert @person.objectives.pluck(:name).include?("Learning")
    assert Person.objectives.pluck(:name).include?("Learning")
  end

  test "should validate character length of custom descriptions" do
    @person.custom_objectives = ["Learning anything up in here is cool"]
    assert_equal "Objectives has a maximum character length of 20", @person.errors.full_messages.first
  end
end
