class Margin < ActiveRecord::Base

  acts_as_cached

  skip_callback :create, :after, :delete

  belongs_to :item
  belongs_to :sale
  belongs_to :purchase

  scope :in_regions, lambda { |regions| where(sale_region_id: regions).where(purchase_region_id: regions) }
  scope :haulable, lambda { |capacity| where("purchase_min_amount*item_volume <= ?", capacity) }
  scope :affordable, lambda { |isk| where("purchase_min_amount*purchase_price <= ?", isk) }
  scope :profit_sorted, order('sale_created_at DESC').order('purchase_created_at DESC').order('(purchase_price-sale_price) ASC')
  scope :np1, joins(:sale).joins(:purchase)

  def cargo_amount(cargohold)
    return (cargohold/item_volume).floor
  end

  def sale_amount_on_station
    (station_sale_amount == 0) ? sale_amount : station_sale_amount
  end

  def purchase_amount_on_station
    (station_purchase_amount == 0) ? purchase_amount : station_purchase_amount
  end

  def profit(cargo_amount, taxes, budget)
    items_in_trade = (sale_amount_on_station > purchase_amount_on_station) ? purchase_amount_on_station : sale_amount_on_station
    items_in_trade = (items_in_trade > cargo_amount) ? cargo_amount : items_in_trade
    items_to_purchase = (items_in_trade * sale_price <= budget) ? items_in_trade : (budget / sale_price).floor
    items_to_purchase = items_in_trade if items_to_purchase > items_in_trade
    profit = ((purchase_price - sale_price)*items_to_purchase) - (items_to_purchase * sale_price * (1-taxes))

    return profit, items_to_purchase
  end

end
