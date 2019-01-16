class FixSpeedsTable < ActiveRecord::Migration[5.1]
  def change
    remove_index :speeds, column: [:store_id, :shipping_speed]
    add_column :speeds, :marketplace, :text
    add_index :speeds, [:marketplace, :shipping_speed, :store_id], unique: true
  end
end
