require_relative "customized"

module Descripto
  module Associated
    extend ActiveSupport::Concern

    include Customized

    included do
      has_many :descriptives, as: :describable, dependent: :destroy, class_name: "Descripto::Descriptive"
      has_many :descriptions, through: :descriptives, class_name: "Descripto::Description"

      has_one :descriptive, as: :describable, dependent: :destroy, class_name: "Descripto::Descriptive"
    end

    module ClassMethods
      def described_by(*types, options)
        define_descripto_getter(types, options)

        types.map(&:to_s).each do |type|
          define_description_associations_for(type)
          define_class_getters_for(type)
          define_validations_for(type, options[:limits])
        end
      end

      def define_descripto_getter(types, options)
        define_singleton_method(:descripto_descriptions) do
          { types:, options: }
        end
      end

      def define_description_associations_for(type)
        if has_one_association?(type)
          define_has_one_description_for(type)
          define_description_getters_for(type)
          define_description_setters_for(type)
        else
          define_has_many_descriptions_for(type)
          define_description_ids_setter_for(type)
        end
      end

      def define_has_one_description_for(type)
        has_one \
          type.to_sym,
          -> { where(description_type: type.singularize) },
          through: :descriptive,
          source: :description,
          class_name: "Descripto::Description"
      end

      def define_has_many_descriptions_for(type)
        has_many \
          type.to_sym,
          -> { where(description_type: type.singularize) },
          through: :descriptives,
          source: :description,
          class_name: "Descripto::Description"
      end

      private

      def has_one_association?(type) # rubocop:disable Naming/PredicateName
        type.singularize.eql?(type)
      end
    end
  end
end
