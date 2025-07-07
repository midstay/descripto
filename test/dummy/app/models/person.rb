# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  has_many :contacts, as: :contactable

  described_by :nationality, :interests,
               options: {
                 interests: { limits: { maximum: 5 } },
                 nationality: { scoped: true }
               }
end
