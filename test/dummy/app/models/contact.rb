class Contact < ApplicationRecord
  include Descripto::Associated

  belongs_to :contactable, polymorphic: true

  described_by :job_position
end
