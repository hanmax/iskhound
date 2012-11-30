class Region < ActiveRecord::Base
  acts_as_cached
  attr_accessible :name
  has_many :offers
  has_many :sales
  has_many :purchases
end
