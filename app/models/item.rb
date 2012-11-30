class Item < ActiveRecord::Base

  acts_as_cached
  attr_accessible :name, :volume
  has_many :sales
  has_many :purchases
  has_many :reprocesses  
  has_one  :margin
  has_one  :reprocess

  scope :with_real_volume, where("volume > 0 AND volume <= 2000000000")

 

  def reprocess_price
    total_cost = 0
    materials = Reprocess.where(item_id: self.id)
    materials.each do |material|
      current_cost = Purchase.where(item_id: material.material_id).where(range: -1).where(region_id: 60003760).order("created DESC").limit(1).first
      current_cost = (current_cost.nil?) ? 0 : current_cost.price
      total_cost += material.quantity * current_cost
    end
    ((total_cost * 0.89) * (1-0.0299) * 0.991)/self.stack_size.round(2)
  end  

  def self.breaker
    sales = Purchase.where(station_id: 60003760)
    #Sale.where(region_id: [10000002]).where("price < ?", 25000000).order("price DESC")
    sales.each do |sale|
      unless sale.item.nil?
        reprice = sale.item.reprocess_price.floor
        saleprice = sale.price.floor
        unless reprice == 0
          if reprice > 0 && saleprice < reprice && sale.amount > 30 && (reprice-saleprice) * sale.amount > 1000000 && saleprice != 0
            profit = (reprice-saleprice)/1000.round(2)
            puts "OK - #{sale.item.name} - (#{reprice} vs. #{saleprice}) - profit: #{profit}k * #{sale.amount}--- #{sale.region.name} --- #{sale.solar_system.name}"
          end
        end
      end
    end
  end

end
