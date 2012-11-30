class AddRangeToPurchases < ActiveRecord::Migration
  def change
    add_column :purchases, :range, :integer    
  end
end
