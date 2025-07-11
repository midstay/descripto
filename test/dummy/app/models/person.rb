# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  described_by :nationality, :interests,
               options: {
                 interests: { limits: { maximum: 5 } },
                 nationality: { scoped: true }
               }

  validate :nationality_must_be_scoped

  def nationality_must_be_scoped
    return if nationality.description_type == "person_nationality"

    errors.add(:nationality,
               "must be scoped")
  end
end
