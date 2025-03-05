require "active_support/concern"

module Descripto
  module Customized
    extend ActiveSupport::Concern

    module ClassMethods
      def define_class_getters_for(type, scoped_type)
        define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type: scoped_type, unique: false)
        end

        Description.define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type: scoped_type, unique: false)
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
          descriptions = descriptions_from_strings(type, strings, options, unique: false)
          send("#{type}=", descriptions) if descriptions.present?
        end

        define_method("custom_#{type}<<") do |strings|
          descriptions = descriptions_from_strings(type, strings, options, unique: false)
          send("#{type}<<", descriptions) if descriptions.present?
        end

        return unless options[:allow_unique]

        define_method("unique_#{type}=") do |strings|
          descriptions = descriptions_from_strings(type, strings, options, unique: true)
          send("#{type}=", descriptions) if descriptions.present?
        end

        define_method("unique_#{type}<<") do |strings|
          descriptions = descriptions_from_strings(type, strings, options, unique: true)
          send("#{type}<<", descriptions) if descriptions.present?
        end
      end

      def define_description_ids_setter_for(type)
        define_method("#{type.singularize}_ids=") do |ids|
          ids_array = [ids].flatten.compact_blank.map(&:to_i)
          send("#{type}=", Description.find(ids_array))
        end
      end

      def define_uniqueness_validation_for(type, options)
        define_method("#{type}_uniqueness") do |allow_custom|
          return if allow_custom

          if send(type).find(&:unique?)
            errors.add(type, "are not allowed to be unique")
          end
        end
      end

      def define_validations_for(type, options)
        return if has_one_association?(type)

        if options.dig(:limits, :maximum)
          validates type, length: {
            too_short: "must have at least %{count} #{type}(s)",
            too_long: "must have at most %{count} #{type}(s)"
          }.merge(options[:limits].slice(:maximum))
        end

        define_uniqueness_validation_for(type, options)

        validate -> { send("#{type}_uniqueness", options[:allow_custom]) }
      end
    end

    # Loads the description that was set in the custom setter
    def cached_description_for(type, scoped_type)
      Description.where(description_type: type, id: descriptions.map(&:id)).first
    end

    def descriptions_from_strings(type, strings, options, unique: false)
      over_limit = strings.find do |string|
        string.length > options[:limits][:max_chars]
      end

      if over_limit
        errors.add(type, "has a maximum character length of #{options[:limits][:max_chars]}")
        return
      end

      strings.map do |string|
        Description.create(description_type: type.singularize, name: string, name_key: string.underscore, unique:)
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
