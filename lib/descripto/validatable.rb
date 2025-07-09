require "active_support/concern"

module Descripto
  module Validatable
    extend ActiveSupport::Concern

    module ClassMethods
      def define_validations_for(type, options)
        define_length_validation(type, options) if should_validate_length?(type, options)
      end

      private

      def should_validate_length?(type, options)
        !has_one_association?(type) && options[:limits]
      end

      def define_length_validation(type, options)
        validates type, length: {
          too_short: "must have at least %<count>s #{type}(s)",
          too_long: "must have at most %<count>s #{type}(s)"
        }.merge(options[:limits])
      end
    end
  end
end
