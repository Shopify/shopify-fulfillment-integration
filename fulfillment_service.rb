require './base'
require 'attr_encrypted'
require 'active_fulfillment'

class FulfillmentService < ActiveRecord::Base
  belongs_to :shop
  attr_encrypted :username, :key => ShopifyApp::SECRET, :attribute => 'username_encrypted'
  attr_encrypted :password, :key => ShopifyApp::SECRET, :attribute => 'password_encrypted'
  validates_presence_of :username, :password
  validates :shop, uniqueness: true
  before_save :check_credentials

  def service
    @service = ActiveMerchant::Fulfillment::ShipwireService.new(
      :login => username,
      :password => password
    )
  end

  def check_credentials
    unless service.valid_credentials?
      errors.add(:password, "Must have valid shipwire credentials to use the services provided by this app.")
      return false
    end
  end

end
