class SetupEverything < ActiveRecord::Migration[5.1]
  def change
    create_table "amazons", force: :cascade do |t|
      t.text "auth_token"
      t.text "marketplace"
      t.integer "store_id"
      t.boolean "three_speed"
      t.text "seller_id"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.index ["store_id"], name: "index_amazons_on_store_id", unique: true
    end
    
    create_table "speeds", force: :cascade do |t|
      t.string "shipping_speed"
      t.boolean "fixed", default: false
      t.decimal "fixed_amount", precision: 5, scale: 2
      t.boolean "flex", default: false
      t.string "flex_dollar_or_percent"
      t.decimal "flex_amount", precision: 5, scale: 2
      t.boolean "free", default: false
      t.float "free_shipping_amount"
      t.datetime "created_at", null: false
      t.datetime "updated_at", null: false
      t.integer "store_id"
      t.boolean "enabled", default: false
      t.index ["store_id", "shipping_speed"], name: "index_speeds_on_store_id_and_shipping_speed", unique: true
    end
    
      create_table "stores", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "owner_id"
    t.boolean "setup", default: false
    t.text "token"
    t.string "webhook_id", default: [], array: true
    t.string "bc_hash"
    t.string "currency_symbol"
    t.string "currency_code"
    t.string "domain"
    t.index ["owner_id"], name: "index_stores_on_owner_id", unique: true
  end

  create_table "zones", force: :cascade do |t|
    t.string "zone_name"
    t.integer "bc_zone_id"
    t.integer "store_id"
    t.boolean "selected", default: false
    t.index ["zone_name", "bc_zone_id", "store_id"], name: "index_zones_on_zone_name_and_bc_zone_id_and_store_id", unique: true
  end

    add_foreign_key "amazons", "stores"
    add_foreign_key "speeds", "stores"
    add_foreign_key "zones", "stores"
  end
end
