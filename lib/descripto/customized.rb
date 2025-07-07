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

        return unless options[:polymorphic_scoped]

        define_singleton_method("#{type.to_s.pluralize}_for") do |describable|
          Description.where(description_type: scoped_type, class_name: describable.class.name)
        end
      end

      def define_description_getters_for(type, scoped_type)
        # Super cannot be called directly inside a method definition
        super_getter = instance_method(type.to_sym)
        define_method(type) do
          super_getter.bind_call(self).presence || cached_description_for(type, scoped_type)
        end

        define_method("#{type}_id") do
          send(type)&.id
        end
      end

      # The has_one "type setter" must be overridden as the has_one "description" setter
      # unsets them if there are multiple being set in the same transaction.
      def define_description_setters_for(type)
        define_method("#{type}=") do |description|
          descriptive = descriptive_of_type(type)
          return if description_exists?(description, descriptive)

          descriptive&.destroy
          descriptions << description if description.present?
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
    def cached_description_for(type, scoped_type)
      Description.where(description_type: type, id: descriptions.map(&:id)).first
    end

    def descriptive_of_type(type)
      descriptives.find { |d| d.description_id.eql?(send(type)&.id) }
    end

    def description_exists?(description, descriptive)
      descriptive&.description_id.eql?(description.presence&.id)
    end
  end
end
