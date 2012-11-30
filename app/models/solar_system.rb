class SolarSystem < ActiveRecord::Base
  acts_as_cached
  attr_accessible :name, :security
  has_many :offers
  has_many :sales
  has_many :purchases
=begin
  scope :zero_security, where ('security < 0.2')
  scope :low_security, where ('security > ? AND < ?', 0.1, 0.5)
  scope :high_security, where ('security > ?', 0.4)
  scope :low_and_high_security, where ('security > ?', 0.1)
=end
end
