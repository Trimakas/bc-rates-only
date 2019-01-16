class AddCountryCode < ActiveRecord::Migration[5.1]
  def change
    add_column :amazons, :country_code, :string
  end
end
