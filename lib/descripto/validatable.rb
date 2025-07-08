require "active_support/concern"

module Descripto
  module Validatable
    extend ActiveSupport::Concern

    module ClassMethods
      def define_validations_for(type, options)
        define_length_validation(type, options) if should_validate_length?(type, options)
        define_class_name_validation(type, options) if should_validate_class_name?(options)
      end

      private

      def should_validate_length?(type, options)
        !has_one_association?(type) && options[:limits]
      end

      def should_validate_class_name?(options)
        return false unless options[:polymorphic_scoped]

        unless options[:allowed_classes]
          raise ArgumentError, "allowed_classes must be provided when polymorphic_scoped is true"
        end

        true
      end

      def define_length_validation(type, options)
        validates type, length: {
          too_short: "must have at least %<count>s #{type}(s)",
          too_long: "must have at most %<count>s #{type}(s)"
        }.merge(options[:limits])
      end

      def define_class_name_validation(type, options)
        allowed_class_names = options[:allowed_classes].map(&:name)

        define_method("validate_#{type}_class_names") do
          descriptions = send(type)
          return unless descriptions.present?

          # Handle both has_one and has_many associations
          descriptions_array = descriptions.is_a?(Array) ? descriptions : [descriptions]

          invalid_class_names = find_invalid_class_names(descriptions_array, allowed_class_names)

          return unless invalid_class_names.any?

          errors.add(type, build_class_name_error(invalid_class_names, allowed_class_names))
        end

        validate "validate_#{type}_class_names".to_sym
      end
    end

    private

    def find_invalid_class_names(descriptions, allowed_class_names)
      descriptions
        .map(&:class_name)
        .uniq
        .reject { |name| allowed_class_names.include?(name) }
    end

    def build_class_name_error(invalid_names, allowed_names)
      "contains descriptions with invalid class names: #{invalid_names.join(", ")}. " \
      "Allowed classes: #{allowed_names.join(", ")}"
    end
  end
end
