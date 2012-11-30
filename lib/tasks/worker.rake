# encoding: UTF-8
ENV['RAILS_ENV'] = "development"

require "./config/environment.rb"
require 'action_view'
require 'httpclient'
require 'colorize'
include ActionView::Helpers::DateHelper


namespace :worker do

  desc "display"

  desc "find margins between buy and sell orders"
  task :margin do
    items = Item.caches(:with_real_volume).flatten
    loop do
      sales = Sale.caches(:margin_sorted)
      purchases = Purchase.caches(:margin_sorted)
      endcount = sales.to_a.count
      sales.each do |sale|
        matched_purchase = purchases.find { |purchase| purchase.item_id == sale.item_id && purchase.price > sale.price && purchase.station_id != sale.station_id }

        unless matched_purchase.nil?
          sale_sum = Sale.caches(:station_amount, with: sale).total_amount
          purchase_sum = Purchase.caches(:station_amount, with: matched_purchase).total_amount

          to_delete = Margin.where(sale_id: sale.id).where(purchase_id: matched_purchase.id).where("(sale_amount != #{sale.amount} OR purchase_amount != #{matched_purchase.amount})")
          to_delete.delete_all

          margin = Margin.new
          margin.item_id = sale.item_id
          margin.item_volume = sale.item.volume
          margin.sale_id = sale.id
          margin.purchase_id = matched_purchase.id
          margin.sale_amount = sale.amount
          margin.sale_min_amount = sale.min_amount
          margin.purchase_amount = matched_purchase.amount
          margin.purchase_min_amount = matched_purchase.min_amount
          margin.sale_price = sale.price
          margin.purchase_price = matched_purchase.price
          margin.sale_station_id = sale.station_id
          margin.purchase_station_id = matched_purchase.station_id
          margin.sale_region_id = sale.region_id
          margin.purchase_region_id = matched_purchase.region_id
          margin.station_sale_amount = sale_sum
          margin.station_purchase_amount = purchase_sum
          margin.sale_created_at = sale.created
          margin.purchase_created_at = matched_purchase.created      

          begin
            margin.save
          rescue
          end          
        end
      end
    end
  end

  task :break do
    a = Sale.least_priced(Reprocess.reprocessible_item_ids)    
    a.uniq.each do |sale|
      brutto = sale.item.reprocessed*0.979*(1-0.0275)*(1-0.009)/sale.item.stack_size
      puts "#{sale.item.name} ---- #{brutto.round(2)} > #{sale.price.round(2)}" if brutto>sale.price
    end      
  end

  task :buybreak do
    Reprocess.group(:item_id).to_a.each do |ritem|
      maxbuy = Sale.where(item_id: ritem.item_id).where(station_id: 60003760).minimum(:price)
      buy = Sale.includes(:item).where(item_id: ritem.item_id).where(station_id: 60003760).order("created DESC, price ASC").limit(1).first
      unless buy.nil?
        brutto = buy.item.reprocessed*0.979*(1-0.0275)*(1-0.009)/buy.item.stack_size      
        puts "#{buy.item.name} : #{brutto.round(2)} > #{buy.price.round(2)} : #{buy.region.name} - #{buy.solar_system.name}" if brutto>buy.price      
      end
    end
  end  
  
  desc "reprocessor"
  task :refine do

    material_ids = Reprocess.material_ids
    reprocessible_item_ids = Reprocess.reprocessible_item_ids
    reprocesses = Reprocess.all

    material_prices = []

    loop do

      raw_prices = Purchase.caches(:material_prices, with: material_ids)
      raw_prices.each do |order|
        material_prices[order.item_id] = order.price
      end
      puts Time.now
      reprocessible_item_ids.each do |item_id|
        print ".. #{item_id} .."
        reprocess_price = 0
        recipe = reprocesses.find_all { |ingridient| ingridient.item_id = item_id }
        begin
          if recipe.class == Array
            recipe.each { |ing| reprocess_price += ing.quantity * material_prices[ing.material_id]}
          else
            reprocess_price = recipe.quantity * material_prices[recipe.material_id]
          end
          item_to_update = Item.find(item_id)
          item_to_update.update_attribute("reprocessed", reprocess_price)      
        rescue
        end
      end
      puts Time.now
      puts '------------------------------'

    end

  end

  desc "speculate"
  task :resell do
    cached_history = []
    client = HTTPClient.new
    items = Item.caches(:with_real_volume).flatten
    loop do
      puts "--------------------------------------------------------------------------------------------------------------------------------------".green
      prev = []
      sales = Sale.includes(:item).where(station_id: 60003760)
      endcount = sales.to_a.count
      sales.each do |sale|
        purchase_max = Purchase.where(station_id: 60003760).where(item_id: sale.item_id).maximum(:price)
        sale_min = Sale.where(station_id: 60003760).where(item_id: sale.item_id).minimum(:price)
        sale_min = 0 if sale_min.nil?
        unless purchase_max.nil?
          if cached_history[sale.item_id].nil?
            content = client.get_content("http://api.eve-marketdata.com/api/item_history2.txt?char_name=iskhound&type_ids=#{sale.item_id}&region_ids=10000002&days=1")
            updates = content.split("\n")
            cached_history[sale.item_id] = updates
          else
            updates = cached_history[sale.item_id]
          end

          unless updates.first.nil? 
            update = updates.first.split("\t")
            trade_amount = (update[6].to_i > (500000000/purchase_max).floor) ? (500000000/purchase_max).floor : update[6].to_i
            daily_profit = trade_amount * (sale_min - purchase_max) * 0.982081
            unless sale.item.reprocessed.nil?
              reprocess = sale.item.reprocessed*0.979*(1-0.0275)*(1-0.009)/sale.item.stack_size
            else
              reprocess = 0
            end
            refine_profit = reprocess - purchase_max

            if (daily_profit > 5000000 && trade_amount > 1000)
              current = "#{update[6]} | #{sale.item.name} | #{daily_profit/1000000.round(2)} mil ISK | sale: #{sale_min} | purchase: #{purchase_max}".cyan
              puts current unless prev.include? current
              prev.push current
            end
            if refine_profit > 0 && trade_amount > 500
              current = "#{trade_amount}/#{update[6]} daily sales | #{sale.item.name} | purchase: #{purchase_max} | reprocess: #{reprocess}".yellow
              puts current unless prev.include? current
              prev.push current
            end
            if refine_profit > 0 && sale_min < reprocess
              current = "#{trade_amount}/#{update[6]} daily sales | #{sale.item.name} | sale: #{sale_min} | reprocess: #{reprocess}".red
              puts current unless prev.include? current
              prev.push current
            end

          end
        end
      end
    end    
  end

end 


=begin
# encoding: UTF-8
ENV['RAILS_ENV'] = "development"
require "./config/environment.rb"

namespace :worker do

  desc "find margins between buy and sell orders"
  task :margin do
    items = Item.caches(:with_real_volume).flatten
    loop do
      sales = Sale.caches(:margin_sorted)
      purchases = Purchase.caches(:margin_sorted)
      endcount = sales.to_a.count
      sales.each do |sale|
        matched_purchase = purchases.find { |purchase| purchase.item_id == sale.item_id && purchase.price > sale.price && purchase.station_id != sale.station_id }

        unless matched_purchase.nil?
          sale_sum = Sale.caches(:station_amount, with: sale).total_amount
          purchase_sum = Purchase.caches(:station_amount, with: matched_purchase).total_amount

          to_delete = Margin.where(sale_id: sale.id).where(purchase_id: matched_purchase.id).where("(sale_amount != #{sale.amount} OR purchase_amount != #{matched_purchase.amount})")
          to_delete.delete_all

          margin = Margin.new
          margin.item_id = sale.item_id
          margin.item_volume = sale.item.volume
          margin.sale_id = sale.id
          margin.purchase_id = matched_purchase.id
          margin.sale_amount = sale.amount
          margin.sale_min_amount = sale.min_amount
          margin.purchase_amount = matched_purchase.amount
          margin.purchase_min_amount = matched_purchase.min_amount
          margin.sale_price = sale.price
          margin.purchase_price = matched_purchase.price
          margin.sale_station_id = sale.station_id
          margin.purchase_station_id = matched_purchase.station_id
          margin.sale_region_id = sale.region_id
          margin.purchase_region_id = matched_purchase.region_id
          margin.station_sale_amount = sale_sum
          margin.station_purchase_amount = purchase_sum
          margin.sale_created_at = sale.created
          margin.purchase_created_at = matched_purchase.created      

          begin
            margin.save
          rescue
          end          
        end
      end
    end
  end
=end
