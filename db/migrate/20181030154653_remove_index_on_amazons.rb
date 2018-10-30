class RemoveIndexOnAmazons < ActiveRecord::Migration[5.1]
  def change
    remove_index :amazons, :store_id
  end
end
