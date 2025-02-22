require_relative "../test_helper"

class PersonTest < ActiveSupport::TestCase
  setup do
    @person = people(:jan_tore)
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
end
