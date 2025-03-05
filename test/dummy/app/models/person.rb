# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  described_by :nationality, :interests, :objectives,
               options: {
                 interests: { limits: { maximum: 5 } },
                 nationality: { scoped: true },
                 objectives: { allow_custom: true, allow_unique: true }
               }
end
