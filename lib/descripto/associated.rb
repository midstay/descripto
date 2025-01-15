require_relative 'customized'
require_relative 'limited'

module Descripto
  module Associated
    extend ActiveSupport::Concern

    include Limited
    include Customized

    included do
      has_many :descriptives,
               as: :describable,
               dependent: :destroy,
               class_name: 'Descripto::Descriptive'
      has_many :descriptions,
               through: :descriptives,
               class_name: 'Descripto::Description'

      has_one :descriptive,
              as: :describable,
              dependent: :destroy,
              class_name: 'Descripto::Descriptive'
    end

    module ClassMethods
      def define_description_relations
        description_types.each do |type|
          define_description_associations_for(type)
          define_class_getters_for(type)
        end
      end

      def description_types
        types_module = const_get('Description::Types')
        types_module.all.map do |type|
          one_description?(type) ? type : type.pluralize
        end
      end

      def define_description_associations_for(type)
        if one_description?(type)
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
          class_name: 'Descripto::Description'
      end

      def define_has_many_descriptions_for(type)
        has_many \
          type.to_sym,
          -> { where(description_type: type.singularize) },
          through: :descriptives,
          source: :description,
          class_name: 'Descripto::Description'
      end

      private

      def one_description?(type)
        description_limit_for(type.singularize).eql?(1)
      end
    end
  end
end
