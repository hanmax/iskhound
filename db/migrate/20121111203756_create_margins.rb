class CreateMargins < ActiveRecord::Migration
  def change
    create_table :margins do |t|
      t.integer :item_id
      t.float :item_volume
      t.integer :sale_id
      t.integer :purchase_id
      t.integer :sale_amount
      t.integer :sale_min_amount
      t.integer :purchase_amount
      t.integer :purchase_min_amount
      t.float   :sale_price
      t.float   :purchase_price
      t.integer :sale_station_id
      t.integer :purchase_station_id
      t.integer :sale_region_id
      t.integer :purchase_region_id
      t.integer :station_sale_amount
      t.integer :station_purchase_amount
      t.datetime :sale_created_at
      t.datetime :purchase_created_at
    end

    add_index :margins, :sale_id
    add_index :margins, :purchase_id
  end
end
