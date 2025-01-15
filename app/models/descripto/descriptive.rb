module Descripto
  class Descriptive < Descripto.model_parent_class.constantize
    self.table_name = Descripto.descriptives_table_name

    belongs_to :description
    belongs_to :describable, polymorphic: true, touch: true

    validates :description, uniqueness: { scope: %i[describable_type describable_id] }
  end
end
