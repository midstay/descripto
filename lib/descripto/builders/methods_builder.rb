require_relative "base_builder"

module Descripto
  module Builders
    class MethodsBuilder < BaseBuilder
      def run
        define_scope
        define_id_getter unless collection?
        define_id_setter unless collection?
      end

      private

      def define_scope
        # Capture instance variable into a local so it's available
        # when this lambda runs in the context of the model
        description_type = scoped_type

        model.define_singleton_method(type.to_s.pluralize) do
          Descripto::Description.where(description_type:)
        end

        Description.define_singleton_method(type.to_s.pluralize) do
          Description.where(description_type:)
        end
      end

      def define_id_getter
        # Capture instance variable into a local so it's available
        # when this lambda runs in the context of the model
        type = @type

        model.define_method("#{type}_id") do
          send(type)&.id
        end
      end

      def define_id_setter
        # Capture instance variable into a local so it's available
        # when this lambda runs in the context of the model
        type = @type

        model.define_method("#{type}_id=") do |id|
          send("#{type}=", Description.find_by(id:))
        end
      end
    end
  end
end