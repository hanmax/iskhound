class Offer < ActiveRecord::Base  
  attr_accessible :item_id, :order_id, :buy, :price, :amount, :min_amount, :region_id, :solar_system_id, :station_id
  belongs_to :item
  belongs_to :region
  belongs_to :solar_system

  scope :liftable, lambda { |capacity| where("min_amount*items.volume <= ?", capacity) }
  scope :top_priced_and_available, order("price DESC, amount DESC")
  scope :in_regions, lambda { |region| where(region_id: region)}
  scope :sales, includes(:item).where(buy: false)
  scope :purchases, includes(:item).where(buy: true)

  # Override attributes
  def amount
    if buy
      Offer.purchases.where(item_id: item_id).where(station_id: station_id).where('price >= ?', price * 0.98).sum(:amount).to_f
    else
      Offer.sales.where(item_id: item_id).where(station_id: station_id).where('price <= ?', price).sum(:amount).to_f
    end
  end

  def matching_sales
    condition = "(station_id != #{self.station_id} AND item_id = #{self.item_id} AND price <= #{self.price*0.9})"
    Offer.sales.where(condition).group(:item_id, :station_id)
  end

end
