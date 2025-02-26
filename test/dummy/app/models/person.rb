# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  described_by :nationality, :interests,
               interests: { limits: { maximum: 5 } },
               nationality: { scoped: true }
end
