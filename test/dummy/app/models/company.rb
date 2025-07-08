class Company < ApplicationRecord
  include Descripto::Associated

  has_many :contacts, as: :contactable

  described_by :nationality, :gender
end
