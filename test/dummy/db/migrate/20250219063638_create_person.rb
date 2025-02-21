class CreatePerson < ActiveRecord::Migration[7.2]
  def change
    create_table :people do |t|
      t.string :name
      t.timestamps
    end
  end
end
