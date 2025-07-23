module Descripto
  module Builders
    class BaseBuilder
      class << self
        def build(model, type)
          new(model, type).run
        end
      end

      def initialize(model, type)
        @model = model
        @type = type.to_sym
      end

      def run; end

      private

      attr_reader :model, :type

      def collection?
        type.to_s.pluralize == type.to_s
      end

      def scoped_type
        @scoped_type ||= model.description_type_for(type)
      end

      def options
        @options ||= model.descripto_descriptions[:options][type] || {}
      end
    end
  end
end