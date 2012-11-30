class CreateMineralPrices < ActiveRecord::Migration
  def change
    create_table :mineral_prices do |t|
      t.integer :id
      t.float :price
    end
  end
end
