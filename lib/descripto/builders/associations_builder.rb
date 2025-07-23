require_relative "base_builder"

module Descripto
  module Builders
    class AssociationsBuilder < BaseBuilder
      def run
        define_descriptive_association
        define_description_association
      end

      private

      def define_descriptive_association
        model.send(
          association_type,
          descriptive_association_name,
          scoped_descriptives,
          as: :describable,
          class_name: "Descripto::Descriptive"
        )
      end

      def define_description_association
        model.send(
          association_type,
          type,
          through: descriptive_association_name,
          source: :description,
          class_name: "Descripto::Description"
        )
      end

      def descriptive_association_name
        if collection?
          :"#{type.to_s.singularize}_descriptives"
        else
          :"#{type}_descriptive"
        end
      end

      def association_type
        if collection?
          :has_many
        else
          :has_one
        end
      end

      def scoped_descriptives
        # Capture instance variable into a local so it's available
        # when this lambda runs in the context of the model
        description_type = scoped_type

        -> { includes(:description).where(descripto_descriptions: { description_type: }) }
      end
    end
  end
end