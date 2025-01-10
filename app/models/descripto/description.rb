# == Schema Information
#
# Table name: descriptions
#
#  id               :bigint           not null, primary key
#  category         :string
#  description_type :string
#  name             :string
#  name_key         :string
#  created_at       :datetime         not null
#  updated_at       :datetime         not null
#
module Descripto
  class Description < ActiveRecord::Base
    self.table_name = 'descriptions'

    has_many :descriptives, dependent: :destroy

    validates :name, uniqueness: { scope: %i[category description_type] }
  end
end