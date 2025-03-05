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
      def described_by(*types, options: {})
        define_descripto_getters(types, options)

        types.map(&:to_s).each do |type|
          scoped_type = description_type(type.to_sym)

          define_description_associations_for(type, scoped_type, options[type.to_sym])
          define_class_getters_for(type, scoped_type)
          define_validations_for(type, options[type.to_sym]) if options.present?
        end
      end

      def define_descripto_getters(types, options)
        define_singleton_method(:descripto_descriptions) do
          { types:, options: }
        end

        define_singleton_method(:description_type_for) do |association_name|
          description_type(association_name.to_sym)
        end
      end

      def define_description_associations_for(type, scoped_type, options)
        if has_one_association?(type)
          define_has_one_description_for(type, scoped_type)
          define_description_getters_for(type, scoped_type)
          define_has_one_description_setters_for(type)
        else
          define_has_many_descriptions_for(type, scoped_type)
          define_description_ids_setter_for(type)
          define_has_many_description_setters_for(type, options)
        end
      end

      def define_has_one_description_for(type, scoped_type)
        has_one \
          type.to_sym,
          -> { where(description_type: scoped_type) },
          through: :descriptive,
          source: :description,
          class_name: "Descripto::Description"
      end

      def define_has_many_descriptions_for(type, scoped_type)
        has_many \
          type.to_sym,
          -> { where(description_type: scoped_type) },
          through: :descriptives,
          source: :description,
          class_name: "Descripto::Description"
      end

      private

      def has_one_association?(type) # rubocop:disable Naming/PredicateName
        type.singularize.eql?(type)
      end

      def description_type(type)
        options = descripto_descriptions[:options][type]

        return type.to_s.singularize unless options&.dig(:scoped)

        "#{self.name.parameterize.underscore}_#{type.to_s.singularize}"
      end
    end
  end
end
