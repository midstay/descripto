class Organization < ApplicationRecord
  has_many :persons, dependent: :destroy

  accepts_nested_attributes_for :persons
end
