require_relative "../test_helper"

class ContactTest < ActiveSupport::TestCase
  setup do
    @person_contact = contacts(:john_person_contact)
    @company_contact = contacts(:jane_company_contact)
    @tech_contact = contacts(:mike_tech_contact)
    @person = people(:jan_tore)
    @company = companies(:acme_corp)
  end

  def test_includes_descripto_associated_concern
    assert Contact.included_modules.include?(Descripto::Associated)
    assert Contact.descripto_descriptions[:types].include?(:job_position)
  end

  def test_polymorphic_scoped_option_is_configured
    job_position_options = Contact.descripto_descriptions[:options][:job_position]
    assert job_position_options[:polymorphic_scoped].eql?(true)
  end

  def test_contact_can_have_job_position
    assert @person_contact.job_position.present?
    assert_equal "Software Engineer", @person_contact.job_position.name
  end

  def test_description_type_is_namespaced_for_polymorphic_scoped
    job_position = @person_contact.job_position
    assert_equal "contact_job_position", job_position.description_type
  end

  def test_description_type_for_method_returns_namespaced_type
    assert_equal "contact_job_position", Contact.description_type_for(:job_position)
  end

  def test_job_position_can_be_set_with_description
    new_position = Descripto::Description.create!(
      name: "Data Scientist",
      name_key: "data_scientist",
      description_type: "contact_job_position",
      class_name: "Person"
    )

    @person_contact.job_position = new_position
    @person_contact.save!

    assert_equal new_position, @person_contact.reload.job_position
  end

  def test_class_method_job_positions_returns_all_job_positions
    job_positions = Contact.job_positions
    assert(job_positions.all? { |jp| jp.description_type == "contact_job_position" })
    assert job_positions.count >= 4 # We have 4 in fixtures
  end

  def test_polymorphic_scoped_adds_class_specific_getter_method
    assert Contact.respond_to?(:job_positions_for)
  end

  def test_job_positions_for_person_returns_person_specific_positions
    person_positions = Contact.job_positions_for(@person)

    assert(person_positions.all? { |jp| jp.class_name == "Person" })
    assert(person_positions.all? { |jp| jp.description_type == "contact_job_position" })

    # Should include software_engineer and consultant from fixtures
    position_names = person_positions.map(&:name)
    assert_includes position_names, "Software Engineer"
    assert_includes position_names, "Consultant"
  end

  def test_job_positions_for_company_returns_company_specific_positions
    company_positions = Contact.job_positions_for(@company)

    assert(company_positions.all? { |jp| jp.class_name == "Company" })
    assert(company_positions.all? { |jp| jp.description_type == "contact_job_position" })

    # Should include project_manager and sales_director from fixtures
    position_names = company_positions.map(&:name)
    assert_includes position_names, "Project Manager"
    assert_includes position_names, "Sales Director"
  end

  def test_job_position_persists_with_correct_class_name
    # Create a new contact for a person
    new_contact = Contact.create!(name: "Test Contact", contactable: @person)

    # Assign a job position
    position = Contact.job_positions_for(@person).first
    new_contact.job_position = position
    new_contact.save!

    # Verify the job position is correctly associated
    reloaded_contact = Contact.find(new_contact.id)
    assert_equal position, reloaded_contact.job_position
    assert_equal "Person", reloaded_contact.job_position.class_name
  end

  # Tests for the Validatable concern
  def test_contact_validates_job_position_class_name
    # Create a contact for a person
    contact = Contact.create!(name: "Test Contact", contactable: @person)

    # Create a job position with invalid class name
    invalid_position = Descripto::Description.create!(
      name: "Invalid Position",
      name_key: "invalid_position",
      description_type: "contact_job_position",
      class_name: "InvalidClass"
    )

    # Try to assign the invalid position
    contact.job_position = invalid_position

    # The contact should not be valid and save should fail
    refute contact.save
    assert contact.errors[:job_position].present?
    assert_includes contact.errors[:job_position].first, "contains descriptions with invalid class names: InvalidClass"
    assert_includes contact.errors[:job_position].first, "Allowed classes: Person, Company"
  end

  def test_contact_allows_valid_job_position_class_names
    # Create a contact for a person
    contact = Contact.create!(name: "Test Contact", contactable: @person)

    # Create a job position with valid class name
    valid_position = Descripto::Description.create!(
      name: "Valid Position",
      name_key: "valid_position",
      description_type: "contact_job_position",
      class_name: "Person"
    )

    # Assign the valid position
    contact.job_position = valid_position

    # The contact should be valid
    assert contact.valid?
    assert contact.errors[:job_position].empty?
  end

  def test_contact_validation_works_with_company_class_name
    # Create a contact for a company
    contact = Contact.create!(name: "Test Contact", contactable: @company)

    # Create a job position with valid Company class name
    valid_position = Descripto::Description.create!(
      name: "Valid Company Position",
      name_key: "valid_company_position",
      description_type: "contact_job_position",
      class_name: "Company"
    )

    # Assign the valid position
    contact.job_position = valid_position

    # The contact should be valid
    assert contact.valid?
    assert contact.errors[:job_position].empty?
  end

  def test_contact_validation_passes_when_no_job_position_assigned
    # Create a contact without a job position
    contact = Contact.create!(name: "Test Contact", contactable: @person)

    # The contact should be valid even without a job position
    assert contact.valid?
    assert contact.errors[:job_position].empty?
  end
end
