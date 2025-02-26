# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  described_by :nationality, :interests, options: { limits: { interests: { maximum: 5 } } }
end
