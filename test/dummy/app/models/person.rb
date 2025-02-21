# frozen_string_literal: true

class Person < ApplicationRecord
  include Descripto::Associated

  module Description
    module Types
      INTEREST = "interest"
      NATIONALITY = "nationality"

      def self.all
        constants.map { |name| const_get(name) }
      end
    end

    module Limits
      INTEREST = 5
      NATIONALITY = 1
    end
  end

  define_description_relations
end
