require_relative "../test_helper"

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = people(:jan_tore)
  end

  def test_cannot_add_same_description_twice
    football = descripto_descriptions(:football)

    assert_raises ActiveRecord::RecordInvalid do
      @person.interests << football
    end

    @person.interest_ids = [football.id, football.id]
    assert_equal 1, @person.interests.size
  end

  def test_cannot_add_more_than_limit
    football = descripto_descriptions(:football)
    programming = descripto_descriptions(:programming)
    surfing = descripto_descriptions(:surfing)

    @person.interest_ids = [football.id, programming.id, surfing.id]
    refute @person.valid?
    assert @person.errors.key? :interests
    assert_includes @person.errors[:interests], "must have at most 2 interest(s)"
  end

  def test_description_name_cannot_exceed_max_characters
    long_name = "a" * 51
    description = Descripto::Description.create(
      name: long_name,
      name_key: long_name.parameterize(separator: "_"),
      description_type: "interest"
    )

    @person.assign_attributes(interest_ids: [description.id])

    refute @person.valid?
    assert @person.errors.key?(:interests)
    assert_includes @person.errors[:interests], "name cannot exceed 50 characters"
  end

  def test_adds_description_with_concern_inclusion
    assert Person.included_modules.include?(Descripto::Associated)

    assert Person.descripto_descriptions[:types].include?(:interests)

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

  def test_should_scope_description_type_if_scoped
    interest_options = Person.descripto_descriptions[:options][:interests]
    assert interest_options[:scoped].blank?

    interests_description_type = Person.first.interests.first.description_type
    assert interests_description_type.exclude?("person")

    nationality_options = Person.descripto_descriptions[:options][:nationality]
    assert nationality_options[:scoped].eql?(true)

    nationality_description_type = Person.first.nationality.description_type
    assert nationality_description_type.include?("person")
  end
end
