require_relative "../test_helper"

class OrganizationTest < ActiveSupport::TestCase
  test "create organization with persons" do
    assert_difference "Organization.count" do
      assert_difference "Person.count" do
        assert_difference "Descripto::Descriptive.count" do
          Organization.create(
            name: "Midstay",
            persons_attributes: [
              { name: "Jan Tore", nationality_id: Person.nationalities.first.id }
            ]
          )
        end
      end
    end
  end

  test "update organization with persons" do
    organization = organizations(:midstay)
    first_person = organization.persons.first

    organization.update(persons_attributes: [
                          {
                            id: first_person.id,
                            name: "#{first_person.name} updated",
                            nationality_id: descripto_descriptions(:indonesian).id
                          }
                        ])

    assert_equal descripto_descriptions(:indonesian), first_person.nationality
  end
end
