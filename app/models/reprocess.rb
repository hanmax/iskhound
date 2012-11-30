class Reprocess < ActiveRecord::Base

  acts_as_cached

  attr_accessible :item_id, :material_id, :quantity
  belongs_to :item
  belongs_to :purchase, foreign_key: "material_id", class_name: "Purchase"

  scope :unique_materials, group(:material_id)
  scope :reprocessible_items, group(:item_id)

  def self.material_ids
    caches(:unique_materials).map(&:material_id)
  end

  def self.reprocessible_item_ids
    caches(:reprocessible_items).map(&:item_id)
  end

end
