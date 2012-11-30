class AddReprocessPriceToItems < ActiveRecord::Migration
  def change
    add_column :items, :reprocessed, :float
  end
end
