class CreateReprocesses < ActiveRecord::Migration
  def change
    create_table :reprocesses do |t|
      t.integer :item_id
      t.integer :material_id
      t.integer :quantity

      t.timestamps
    end
  end
end
