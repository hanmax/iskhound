class ProfitController < ApplicationController

  def index
    # until parameters population, use predefined values
    @taxes = 0.991
    @isk = 133000000
    @cargo = 13319
    region_list = [ 10000002, 10000043 ]
    @min_profit = 1000000

    #@margin_trades = Margin.caches(:in_regions, with: region_list).caches(:haulable, with: @cargo).caches(:affordable, with: @isk).caches(:np1).caches(:profit_sorted).uniq
    @margin_trades = Margin.haulable(@cargo).affordable(@isk).np1.profit_sorted
    #@margin_trades = Margin.in_regions(region_list).haulable(@cargo).affordable(@isk).np1.profit_sorted

  end

  def obsolete_sale
    sale = Sale.where(id: params[:id])
    sale.delete_all unless sale.nil?
    redirect_to ({ action: 'index' })
  end

  def obsolete_buy
    buy = Purchase.where(id: params[:id])
    buy.delete_all unless buy.nil?
    redirect_to ({ action: 'index' })
  end

  def obsolete
    margin = Margin.find(params[:id])
    Purchase.where(id: margin.purchase_id).delete_all
    Sale.where(id: margin.sale_id).delete_all
    Margin.where(id: params[:id]).delete_all
    redirect_to ({ action: 'index' })
  end

  def scan
  end
end
