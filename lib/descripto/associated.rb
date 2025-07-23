require "active_support/concern"
require_relative "builders/associations_builder"
require_relative "builders/methods_builder"
require_relative "builders/validations_builder"

module Descripto
  module Associated
    extend ActiveSupport::Concern

    included do
      class_attribute :descripto_descriptions, instance_accessor: false

      private_class_method :descripto_descriptions=
    end

    module ClassMethods
      def described_by(*types, options: {})
        self.descripto_descriptions = { types:, options: }.with_indifferent_access

        types.each do |type|
          %w[Associations Methods Validations].each do |builder|
            builder_class = "Descripto::Builders::#{builder}Builder"
            builder_class.constantize.build(self, type)
          end
        end
      end

      def description_type_for(type)
        options = descripto_descriptions[:options][type]

        return type.to_s.singularize unless options&.dig(:scoped)

        "#{name.parameterize.underscore}_#{type.to_s.singularize}"
      end
    end
  end
end
