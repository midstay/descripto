require_relative "../test_helper"

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = persons(:jan_tore)
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
      description_type: "person_nationality"
    )

    @person.nationality_id = nationality.id
    @person.save

    assert @person.reload.nationality == nationality
  end

  test "has_one association works correctly for new objects" do
    nationality_desc = descripto_descriptions(:norwegian)

    # Scenario 1: Person.new(nationality_id: id).save should work
    person1 = Person.new(
      name: "Test Person 1",
      nationality_id: nationality_desc.id,
      organization: organizations(:midstay)
    )
    assert_equal nationality_desc, person1.nationality, "Person.new(nationality_id: id) should work"
    assert_equal nationality_desc.id, person1.nationality_id, "nationality_id should be set correctly"
    assert person1.save, "Person should save successfully"

    # Scenario 2: Setting nationality= should work
    person2 = Person.new(
      name: "Test Person 2",
      organization: organizations(:midstay)
    )
    person2.nationality = nationality_desc
    assert_equal nationality_desc, person2.nationality, "Setting nationality= should work"
    assert_equal nationality_desc.id, person2.nationality_id, "nationality_id should be set correctly"
    assert person2.save, "Person should save successfully"

    # Scenario 3: Setting nationality_id= should work
    person3 = Person.new(
      name: "Test Person 3",
      organization: organizations(:midstay)
    )
    person3.nationality_id = nationality_desc.id
    assert_equal nationality_desc, person3.nationality, "Setting nationality_id= should work"
    assert_equal nationality_desc.id, person3.nationality_id, "nationality_id should be set correctly"
    assert person3.save, "Person should save successfully"

    # Scenario 4: Validations should work without crashing
    person4 = Person.new(
      name: "Test Person 4",
      nationality_id: nationality_desc.id,
      organization: organizations(:midstay)
    )
    assert person4.valid?, "Person should be valid"
  end

  test "should be able to create person" do
    assert_difference "Person.count" do
      nationality = descripto_descriptions(:norwegian)

      person = Person.new(
        name: "John Doe",
        organization: organizations(:midstay),
        nationality:
      )

      person.save
    end
  end

  test "update person with contact" do
    person = persons(:jan_tore)
    contact = person.contact
    job_position = descripto_descriptions(:cto)

    person.update(contact_attributes: {
                    job_position_id: job_position.id
                  })

    assert_equal job_position, contact.job_position
  end
end
