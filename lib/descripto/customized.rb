require "active_support/concern"

module Descripto
  module Customized
    extend ActiveSupport::Concern

    module ClassMethods
      def define_class_getters_for(type, scoped_type)
        define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type: scoped_type)
        end

        Description.define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type: scoped_type)
        end
      end

      def define_description_getters_for(type, scoped_type)
        # Super cannot be called directly inside a method definition
        super_getter = instance_method(type.to_sym)
        define_method(type) do
          super_getter.bind_call(self).presence || description_for(scoped_type)
        end

        define_method("#{type}_id") do
          send(type)&.id
        end
      end

      # The has_one "type setter" must be overridden as the has_one "description" setter
      # unsets them if there are multiple being set in the same transaction.
      def define_description_setters_for(type)
        define_method("#{type}=") do |description|
          current_description = send(type)
          return if current_description == description

          descriptives.where(description: current_description).destroy_all if current_description

          descriptions << description if description.present?

          # Reset getter cache so it sees the new state
          # Don't reset descriptives association as it would clear the built object
          association(type.to_sym).reset
        end

        define_method("#{type}_id=") do |id|
          send("#{type}=", Description.find_by(id:))
        end
      end

      def define_description_ids_setter_for(type)
        define_method("#{type.singularize}_ids=") do |ids|
          ids_array = [ids].flatten.compact_blank.map(&:to_i)
          send("#{type}=", Description.find(ids_array))
        end
      end

      def define_validations_for(type, options)
        return if has_one_association?(type)

        return unless options[:limits]

        validates type, length: {
          too_short: "must have at least %<count>s #{type}(s)",
          too_long: "must have at most %<count>s #{type}(s)"
        }.merge(options[:limits])
      end
    end

    # Loads the description that was set in the custom setter
    def description_for(scoped_type)
      # First check in-memory built descriptive associations (fast cache lookup)
      # This handles the case where associations are built but not yet saved
      cached_description_for(scoped_type) ||
        # If not found in memory, fall back to persisted descriptions (slower DB query)
        Description.where(description_type: scoped_type, id: descriptions.map(&:id)).first
    end

    def cached_description_for(scoped_type)
      descriptives.find do |descriptive|
        descriptive.description&.description_type == scoped_type
      end&.description
    end
  end
end
