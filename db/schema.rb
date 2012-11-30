# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20121119111536) do

  create_table "items", :force => true do |t|
    t.string  "name",        :default => " ",           :null => false
    t.float   "volume",      :default => 10000000000.0, :null => false
    t.integer "stack_size"
    t.float   "reprocessed"
  end

  create_table "jumps", :force => true do |t|
    t.integer "from_system"
    t.integer "to_system"
    t.integer "jumps"
  end

  create_table "margins", :force => true do |t|
    t.integer  "item_id"
    t.float    "item_volume"
    t.integer  "sale_id"
    t.integer  "purchase_id"
    t.integer  "sale_amount"
    t.integer  "sale_min_amount"
    t.integer  "purchase_amount"
    t.integer  "purchase_min_amount"
    t.float    "sale_price"
    t.float    "purchase_price"
    t.integer  "sale_station_id"
    t.integer  "purchase_station_id"
    t.integer  "sale_region_id"
    t.integer  "purchase_region_id"
    t.integer  "station_sale_amount"
    t.integer  "station_purchase_amount"
    t.datetime "sale_created_at"
    t.datetime "purchase_created_at"
  end

  add_index "margins", ["purchase_id"], :name => "index_margins_on_purchase_id"
  add_index "margins", ["sale_id", "purchase_id", "sale_amount", "sale_min_amount", "purchase_amount", "purchase_min_amount", "sale_price", "purchase_price", "sale_station_id", "purchase_station_id"], :name => "sale_id", :unique => true
  add_index "margins", ["sale_id"], :name => "index_margins_on_sale_id"

  create_table "mineral_prices", :force => true do |t|
    t.float "price"
  end

  create_table "offers", :force => true do |t|
    t.integer  "item_id"
    t.integer  "order_id",        :limit => 8
    t.boolean  "buy"
    t.float    "price"
    t.float    "amount"
    t.integer  "min_amount"
    t.integer  "region_id"
    t.integer  "solar_system_id"
    t.integer  "station_id"
    t.datetime "created"
  end

  add_index "offers", ["buy", "price", "min_amount", "region_id"], :name => "buy"
  add_index "offers", ["item_id", "price", "station_id"], :name => "item_id_2"
  add_index "offers", ["order_id"], :name => "index_offers_on_order_id", :unique => true
  add_index "offers", ["station_id"], :name => "station_id"

  create_table "purchases", :force => true do |t|
    t.integer  "item_id"
    t.integer  "order_id",        :limit => 8
    t.float    "price"
    t.float    "amount"
    t.integer  "min_amount"
    t.integer  "region_id"
    t.integer  "solar_system_id"
    t.integer  "station_id"
    t.datetime "created"
    t.integer  "range"
  end

  add_index "purchases", ["amount"], :name => "amount"
  add_index "purchases", ["item_id", "price", "station_id"], :name => "item_id"
  add_index "purchases", ["price", "amount"], :name => "price"

  create_table "regions", :force => true do |t|
    t.string "name"
  end

  create_table "reprocesses", :force => true do |t|
    t.integer  "item_id"
    t.integer  "material_id"
    t.integer  "quantity"
    t.datetime "created_at",  :null => false
    t.datetime "updated_at",  :null => false
  end

  add_index "reprocesses", ["item_id"], :name => "index_reprocesses_on_item_id"

  create_table "sales", :force => true do |t|
    t.integer  "item_id"
    t.integer  "order_id",        :limit => 8
    t.float    "price"
    t.float    "amount"
    t.integer  "min_amount"
    t.integer  "region_id"
    t.integer  "solar_system_id"
    t.integer  "station_id"
    t.datetime "created"
  end

  add_index "sales", ["amount"], :name => "amount"
  add_index "sales", ["item_id", "price", "amount", "created"], :name => "item_id"
  add_index "sales", ["item_id", "price", "station_id"], :name => "item_id_2"
  add_index "sales", ["price", "amount", "created"], :name => "margin_sort"

  create_table "solar_systems", :force => true do |t|
    t.string "name"
    t.float  "security"
  end

  create_table "users", :force => true do |t|
    t.string   "email",                  :default => "", :null => false
    t.string   "encrypted_password",     :default => "", :null => false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          :default => 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                             :null => false
    t.datetime "updated_at",                             :null => false
  end

  add_index "users", ["email"], :name => "index_users_on_email", :unique => true
  add_index "users", ["reset_password_token"], :name => "index_users_on_reset_password_token", :unique => true

end
