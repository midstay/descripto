class CreateVenuesEventSpace < ActiveRecord::Migration[8.0]
  def change
    create_table :venues_event_spaces do |t|
      t.name
      t.timestamps
    end
  end
end
