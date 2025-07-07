class Company < ApplicationRecord
  has_many :contacts, as: :contactable
end
