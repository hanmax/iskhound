class CreateJumps < ActiveRecord::Migration
  def change
    create_table :jumps do |t|
      t.integer :from_system
      t.integer :to_system
      t.integer :jumps
    end
  end
end