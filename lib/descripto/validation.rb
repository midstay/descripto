require "active_support/concern"

module Descripto
  module Validation
    extend ActiveSupport::Concern

    included do
      validate :validate_max_number_of_descriptions
      validate :validate_max_character_per_description
    end

    private

    def validate_max_number_of_descriptions
      self.class.descripto_descriptions[:options].each do |type, options|
        next if self.class.send(:has_one_association?, type)

        next unless options[:limits]

        max_limit = options[:limits][:maximum]
        count = send(type).size

        next unless max_limit && count > max_limit

        errors.add(
          type, "must have at most #{max_limit} #{type.to_s.singularize}(s)"
        )
      end
    end

    def validate_max_character_per_description
      self.class.descripto_descriptions[:options].each do |type, options|
        next unless options[:max_character]

        descriptions = send(type)
        descriptions.each do |desc|
          if desc.name.length > options[:max_character]
            errors.add(type, "name cannot exceed #{options[:max_character]} characters")
          end
        end
      end
    end
  end
end
