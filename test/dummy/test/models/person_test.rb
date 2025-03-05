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

  test "should only return shared descriptions for class" do
    shared_objective = Descripto::Description.create(
      name: "Learning",
      name_key: "learning",
      description_type: "objective",
      unique: false
    )

    unique_objective = Descripto::Description.create(
      name: "Training",
      name_key: "training",
      description_type: "objective",
      unique: true
    )

    assert Person.objectives.include?(shared_objective)
    assert_not Person.objectives.include?(unique_objective)
  end

  test "descriptions can be unique for a describable" do
    objectives_shared = Person.descripto_descriptions[:options][:objectives][:allow_custom]
    assert objectives_shared

    objective = Descripto::Description.create(
      name: "Learning",
      name_key: "learning",
      description_type: "objective",
      unique: true
    )

    assert_difference "Descripto::Descriptive.count", 1 do
      people(:jan_tore).objectives << objective
    end

    person = Person.create(
      name: "John Doe",
      objectives: [objective]
    )

    assert_not person.valid?
    assert_equal "Descriptives is invalid", person.errors.full_messages.first
    assert_equal "Description can only be used once as it is marked as unique",
                 person.descriptives.first.errors.full_messages.first
  end

  test "can not add unique for a describable if not allowed" do
    interests_shared = Person.descripto_descriptions[:options][:interests][:allow_custom]
    refute interests_shared

    interest = Descripto::Description.create(
      name: "Gameboy",
      name_key: "gameboy",
      description_type: "interest",
      unique: true
    )

    person = people(:jan_tore)
    person.interests << interest

    assert_not person.valid?
    assert_equal "Interests are not allowed to be unique", person.errors.full_messages.first
  end

  test "should be able to create custom descriptions from string" do
    assert_difference "Descripto::Description.count", 1 do
      @person.custom_objectives = ["Learning"]
      @person.save
    end

    assert @person.objectives.pluck(:name).include?("Learning")
    assert Person.objectives.pluck(:name).include?("Learning")
  end

  test "should be able to create unique descriptions from string" do
    unique_objectives_allowed = Person.descripto_descriptions[:options][:objectives][:allow_unique]
    custom_objectives_allowed = Person.descripto_descriptions[:options][:objectives][:allow_custom]

    assert unique_objectives_allowed
    assert custom_objectives_allowed

    assert_difference "Descripto::Description.count", 1 do
      @person.unique_objectives = ["Learning"]
      @person.save
    end

    assert @person.objectives.pluck(:name).include?("Learning")

    assert @person.objectives.first.unique
  end
end
