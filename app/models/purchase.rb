class Purchase < ActiveRecord::Base

  attr_accessible :item_id, :order_id, :price, :amount, :min_amount, :region_id, :solar_system_id, :station_id

  acts_as_cached

  belongs_to :item
  belongs_to :region
  belongs_to :solar_system

  has_many :sales, through: :item
  has_many :reprocesses
  has_one  :margin
  has_one  :purchase, through: :margin

  scope :affordable, lambda { |isk| where("(min_amount*price*0.8) <= ?", isk) }
  scope :margin_sorted, group(:item_id).order("created DESC, price DESC, amount DESC")
  scope :station_amount, lambda { |purchase| where(station_id: purchase.station_id).where(item_id: purchase.item_id).where("price > ?", purchase.price*0.95) }    
  scope :material_prices, lambda { |ids| Purchase.select("item_id, price").where(item_id: ids).group(:created).having("created = MAX(created)").where(range: -1).where(station_id: 60003760).order("created DESC").limit(ids.count) }

  def self.total_amount
    sum('amount')
  end

end
