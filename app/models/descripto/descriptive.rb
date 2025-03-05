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
  class Descriptive < ActiveRecord::Base
    belongs_to :description, class_name: "Descripto::Description"
    belongs_to :describable, polymorphic: true, touch: true

    validates :description, uniqueness: { scope: %i[describable_type describable_id] }
    validates :description_id, uniqueness: {
      scope: [],
      if: -> { description&.unique? },
      message: "can only be used once as it is marked as unique"
    }
  end
end
