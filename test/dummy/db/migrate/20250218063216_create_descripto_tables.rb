class CreateDescriptoTables < ActiveRecord::Migration[7.0]
  def change # rubocop:disable Metrics/MethodLength
    create_table :descripto_descriptions do |t|
      t.string :name
      t.string :name_key
      t.string :description_type
      t.string :category

      t.timestamps
    end

    create_table :descripto_descriptives do |t|
      t.references :descripto_description, null: false, foreign_key: true
      t.bigint :describable_id
      t.string :describable_type

      t.timestamps
    end
  end
end
