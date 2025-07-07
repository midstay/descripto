class CreateCompany < ActiveRecord::Migration[8.0]
  def change
    create_table :companies do |t|
      t.string :name

      t.timestamps
    end
  end
end
