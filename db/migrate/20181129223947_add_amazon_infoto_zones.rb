class AddAmazonInfotoZones < ActiveRecord::Migration[5.1]
  def change
    add_column :zones, :seller_id, :string
    add_column :zones, :marketplace, :string
  end
end
