module Description
  module Groupable
    extend ActiveSupport::Concern

    class_methods do
      def grouped(records)
        records
          .order(:name)
          .pluck(:id, :name, :category)
          .group_by(&:third).to_a
          .sort_by(&:first)
      end

      # TODO: Refactor this logic to be more efficient
      # When we refactor to define the description.
      def groupable?(type)
        where(description_type: type).exists?(category: nil).!
      end
    end
  end
end
