# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  described_by :nationality, :interests,
               options: {
                 interests: { limits: { maximum: 2 }, max_character: 50 },
                 nationality: { scoped: true }
               }
end
