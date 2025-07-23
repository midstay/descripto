require_relative "base_builder"

module Descripto
  module Builders
    class ValidationsBuilder < BaseBuilder
      def run
        define_limits if collection? && options[:limits].present?
      end

      private

      def define_limits
        model.validates type, length: {
          too_short: "must have at least %<count>s #{type}(s)",
          too_long: "must have at most %<count>s #{type}(s)"
        }.merge(options[:limits].deep_symbolize_keys)
      end
    end
  end
end