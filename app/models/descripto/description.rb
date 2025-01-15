module Descripto
  class Description < Descripto.model_parent_class.constantize
    self.table_name = Descripto.descriptions_table_name

    has_many :descriptives, dependent: :destroy

    validates :name, uniqueness: { scope: %i[category description_type] }
  end
end
