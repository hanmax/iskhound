class Sale < ActiveRecord::Base

  acts_as_cached

  attr_accessible :item_id, :order_id, :price, :amount, :min_amount, :region_id, :solar_system_id, :station_id

  belongs_to :item
  belongs_to :region
  belongs_to :solar_system

  has_many :purchases, through: :item
  has_one  :margin
  has_one  :sale, through: :margin

  scope :margin_sorted, group(:item_id).order("created DESC, price ASC, amount DESC")
  scope :station_amount, lambda { |sale| where(station_id: sale.station_id).where(item_id: sale.item_id).where("price <= ?", sale.price*1.10) }
  scope :least_priced, lambda { |ids| select("item_id, price").includes(:item).where(item_id: ids).group(:item_id).having("price = MIN(price)").where(station_id: 60003760).where("price < items.reprocessed").order("price ASC").limit(ids.count) } 

  def self.total_amount
    sum('amount')
  end

  def profitable_reprocessed
    profits = []
    sales = Sale.least_priced

  end

end
