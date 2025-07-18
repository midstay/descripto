class CreateContacts < ActiveRecord::Migration[8.0]
  def change
    create_table :contacts do |t|
      t.string :email
      t.references :contactable, polymorphic: true, null: false
      t.timestamps
    end
  end
end
