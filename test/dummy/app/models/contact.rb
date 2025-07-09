class Contact < ApplicationRecord
  include Descripto::Associated

  belongs_to :contactable, polymorphic: true

  described_by :job_position,
               options: {
                 job_position: {
                   polymorphic_scoped: true,
                   scoped_classes: [Person, Company]
                 }
               }
end
