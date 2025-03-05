# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  described_by :nationality, :interests, :objectives,
               options: {
                 interests: { max_items: 5 },
                 nationality: { scoped: true },
                 objectives: { allow_custom: true, max_chars: 20 }
               }
end
