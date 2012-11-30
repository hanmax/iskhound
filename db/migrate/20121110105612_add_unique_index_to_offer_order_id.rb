class AddUniqueIndexToOfferOrderId < ActiveRecord::Migration
  def change
    add_index :offers, :order_id, unique: true
  end
end
