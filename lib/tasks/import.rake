# encoding: UTF-8
ENV['RAILS_ENV'] = "development"

require "./config/environment.rb"
require 'ffi-rzmq'
require 'json'
require 'zlib'
require 'action_view'
require 'httpclient'
include ActionView::Helpers::DateHelper

namespace :import do

  desc "pre-calculate inter-system jump counts"
  task :jumps do
    
    sql = "SELECT id FROM solar_systems WHERE security >= 0.11"
    systems = ActiveRecord::Base.connection.execute(sql).to_a

    systems.each do |system|

    end

  end

  desc "data import loop, from EMDR"
  task :emdr do
    context = ZMQ::Context.new
    subscriber = context.socket(ZMQ::SUB)
    subscriber.connect("tcp://relay-us-east-1.eve-emdr.com:8050")
    subscriber.setsockopt(ZMQ::SUBSCRIBE,"")

    loop do
      subscriber.recv_string(string = '')
      market_json = Zlib::Inflate.new(Zlib::MAX_WBITS).inflate(string)
      market_data = JSON.parse(market_json)
      type = market_data["resultType"]

      if type == 'orders'
        Thread.new do
          market_data["rowsets"].each do |row|
            region = row["regionID"]
            row["rows"].each do |order|

              order_time = Time.parse(order[7]).utc

              if order[6]

                # Buy order
                purchase = Purchase.where(order_id: order[3])                
                older = (purchase.present?) ? purchase.created <= order_time : false
                purchase.delete_all if purchase.present? && older

                unless older
                  new_purchase = Purchase.new
                  new_purchase.item_id = row['typeID']
                  new_purchase.range = order[2]
                  new_purchase.order_id = order[3]
                  new_purchase.region_id = region
                  new_purchase.solar_system_id = order[10]
                  new_purchase.station_id = order[9]
                  new_purchase.price = order[0]
                  new_purchase.amount = order[1]
                  new_purchase.min_amount = order[5]
                  new_purchase.created = order_time
                  new_purchase.save
                end

              else

                # Sale order
                sale = Sale.where(order_id: order[3])                
                older = (sale.present?) ? sale.created <= order_time : false
                sale.delete_all if sale.present? && older

                unless older
                  new_sale = Sale.new
                  new_sale.item_id = row['typeID']
                  new_sale.order_id = order[3]
                  new_sale.region_id = region
                  new_sale.solar_system_id = order[10]
                  new_sale.station_id = order[9]
                  new_sale.price = order[0]
                  new_sale.amount = order[1]
                  new_sale.min_amount = order[5]
                  new_sale.created = order_time
                  new_sale.save
                end
              end


            end
          end
        end
      end
    end
  end

  desc "data import loop, from eve-marketdata"
  task :marketdata do

    client = HTTPClient.new

    loop do
      sleep(30)
      updated_item_ids = []
      content = client.get_content("http://api.eve-marketdata.com/api/recent_uploads2.txt?char_name=iskhound&upload_type=o&minutes=1")
      updates = content.split("\n")
      updates.each do |update|
        update_columns = update.split("\t")
        updated_item_ids.push(update_columns[2].to_i) unless updated_item_ids.include?(update_columns[2].to_i)
      end

      if updated_item_ids.count > 0

        updated_item_ids.each do |item_id|
        to_sales, to_purchases = [],[]
          begin
            output = client.get_content("http://api.eve-marketdata.com/api/item_orders2.txt?char_name=iskhound&buysell=a&type_ids=#{item_id}")
          rescue
            next
          end
          orders = output.split("\n")

          orders.each do |order|
            columns = order.split("\t")
            order_time = Time.parse(columns[11]<<" +0000").utc
            order_type = (columns[0] == 'b') ? 1 : 0
            if order_type == 1

                to_delete = Purchase.where(order_id: columns[2])          
                older = (to_delete.present?) ? to_delete.first.created <= order_time : false
                to_delete.delete_all if to_delete.present? && older                

                unless older
                  purchase = Purchase.new
                  purchase.item_id = columns[1]
                  purchase.order_id = columns[2]
                  purchase.region_id = columns[5]
                  purchase.solar_system_id = columns[4]
                  purchase.station_id = columns[3]
                  purchase.price = columns[6]
                  purchase.amount = columns[8]
                  purchase.min_amount = columns[9]
                  purchase.created = order_time
                  purchase.range = columns[10]
                  purchase.save
                end

            else

                to_delete = Sale.where(order_id: columns[2])          
                older = (to_delete.present?) ? to_delete.first.created <= order_time : false
                to_delete.delete_all if to_delete.present? && older  

                unless older
                  sale = Sale.new
                  sale.item_id = columns[1]
                  sale.order_id = columns[2]
                  sale.region_id = columns[5]
                  sale.solar_system_id = columns[4]
                  sale.station_id = columns[3]
                  sale.price = columns[6]
                  sale.amount = columns[8]
                  sale.min_amount = columns[9]
                  sale.created = order_time
                  sale.save
                end                

            end
          end

        end

      end

    end

  end

end