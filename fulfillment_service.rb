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

  def self.name
    @name ||= YAML.load(File.read("config/fulfillment_service.yml"))["service"]["name"]
  end

  def fetch_stock_levels(options={})
    instance.fetch_stock_levels(options)
  end

  def fetch_tracking_numbers(order_ids)
    instance.fetch_tracking_numbers(order_ids)
  end

  def instance
    @instance = ActiveMerchant::Fulfillment::ShipwireService.new(
      :login => username,
      :password => password,
      :test => true
    )
  end

  def check_credentials
    unless instance.valid_credentials?
      errors.add(:password, "Must have valid shipwire credentials to use the services provided by this app.")
      return false
    end
  end

end
