# frozen_string_literal: true

module Descripto
  module Limited
    extend ActiveSupport::Concern

    class_methods do
      def description_limits
        "#{name}::Description::Limits".constantize
      end

      def description_limit_for(type)
        constant_name = type.singularize.upcase

        if description_limits.const_defined?(constant_name)
          description_limits.const_get(constant_name)
        else
          Float::INFINITY
        end
      end

      def description_above_max?(type, amount)
        amount > description_limit_for(type)
      end
    end
  end
end
