class AddIndexesToReprocesses < ActiveRecord::Migration
  def change
    add_index :reprocesses, :item_id
  end
end
