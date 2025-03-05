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
          super_getter.bind_call(self).presence || cached_description_for(type, scoped_type)
        end

        define_method("#{type}_id") do
          send(type)&.id
        end
      end

      def define_has_one_description_setters_for(type)
        define_method("#{type}_id=") do |id|
          send("#{type}=", Description.find_by(id:))
        end
      end

      def define_has_many_description_setters_for(type, options)
        return unless options[:allow_custom]

        define_method("custom_#{type}=") do |strings|
          descriptions = descriptions_from_strings(type, strings, options)
          send("#{type}=", descriptions) if descriptions.present?
        end

        define_method("custom_#{type}<<") do |strings|
          descriptions = descriptions_from_strings(type, strings, options)
          send("#{type}<<", descriptions) if descriptions.present?
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

        if options[:max_items]
          validates type, length: {
            maximum: options[:max_items],
            too_short: "must have at least %{count} #{type}(s)",
            too_long: "must have at most %{count} #{type}(s)"
          }
        end
      end
    end

    # Loads the description that was set in the custom setter
    def cached_description_for(type, scoped_type)
      Description.where(description_type: type, id: descriptions.map(&:id)).first
    end

    def descriptions_from_strings(type, strings, options)
      over_limit = strings.find do |string|
        string.length > options[:max_chars]
      end

      if over_limit
        errors.add(type, "has a maximum character length of #{options[:max_chars]}")
        return
      end

      strings.map do |string|
        Description.create(description_type: type.singularize, name: string, name_key: string.underscore)
      end
    end

    def descriptive_of_type(type)
      descriptives.find { |d| d.description_id.eql?(send(type)&.id) }
    end

    def description_exists?(description, descriptive)
      descriptive&.description_id.eql?(description.presence&.id)
    end
  end
end
