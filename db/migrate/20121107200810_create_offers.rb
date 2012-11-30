class CreateOffers < ActiveRecord::Migration
  def change
    create_table :offers do |t|
      t.integer :item_id
      t.integer :order_id, limit: 8
      t.boolean :buy
      t.float :price
      t.float :amount
      t.integer :min_amount
      t.integer :region_id
      t.integer :solar_system_id
      t.integer :station_id
      t.datetime :created
    end
  end
end
