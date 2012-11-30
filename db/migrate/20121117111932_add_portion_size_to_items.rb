class AddPortionSizeToItems < ActiveRecord::Migration
  def change
    add_column :items, :stack_size, :integer
  end
end
