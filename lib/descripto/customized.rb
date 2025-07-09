require "active_support/concern"

module Descripto
  module Customized
    extend ActiveSupport::Concern

    module ClassMethods
      def define_class_getters_for(type, scoped_type, options)
        define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type: scoped_type)
        end

        Description.define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type: scoped_type)
        end

        return unless options&.dig(:polymorphic_scoped)

        define_singleton_method("#{type.to_s.pluralize}_for") do |describable|
          Description.where(description_type: scoped_type, class_name: describable.name)
        end
      end

      def define_description_getters_for(type)
        # Super cannot be called directly inside a method definition
        super_getter = instance_method(type.to_sym)
        define_method(type) do
          super_getter.bind_call(self).presence || cached_description_for(type)
        end

        define_method("#{type}_id") do
          send(type)&.id
        end
      end

      # The has_one "type setter" must be overridden as the has_one "description" setter
      # unsets them if there are multiple being set in the same transaction.
      def define_description_setters_for(type) # rubocop:disable Metrics/MethodLength
        define_method("#{type}=") do |description|
          current_description = send(type)
          return if current_description == description

          # Remove existing association for this type
          descriptives.where(description: current_description).destroy_all if current_description

          # Create new association if description present
          descriptives.create!(description: description) if description.present?

          # Reset caches so validations see correct state
          association(type.to_sym).reset
          association(:descriptives).reset
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
    end

    # Loads the description that was set in the custom setter
    def cached_description_for(type)
      Description.where(description_type: type, id: descriptions.map(&:id)).first
    end
  end
end
