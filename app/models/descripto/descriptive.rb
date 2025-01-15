# == Schema Information
#
# Table name: descriptives
#
#  id               :bigint           not null, primary key
#  describable_type :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#  describable_id   :bigint
#  description_id   :bigint           not null
#
# Indexes
#
#  index_descriptives_on_description_id  (description_id)
#
# Foreign Keys
#
#  fk_rails_...  (description_id => descriptions.id)
#
module Descripto
  class Descriptive < Descripto.model_parent_class.constantize
    self.table_name = Descripto.descriptives_table_name

    belongs_to :description
    belongs_to :describable, polymorphic: true, touch: true

    validates :description, uniqueness: { scope: %i[describable_type describable_id] }
  end
end