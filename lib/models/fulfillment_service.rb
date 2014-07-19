require 'sinatra/shopify-sinatra-app'
require 'attr_encrypted'
require 'active_fulfillment'

# This is the fulfillment service model. It holds all of the data
# associated with the service such as the shop it belongs to and the
# credentials (encrypted). It also contains some methods to help translate
# the fulfillment data from a Shopify format into the format expected by the
# fulfillment service.

class FulfillmentService < ActiveRecord::Base

  def self.secret
    ENV['SECRET']
  end

  attr_encrypted :username, :key => secret, :attribute => 'username_encrypted'
  attr_encrypted :password, :key => secret, :attribute => 'password_encrypted'
  validates_presence_of :username, :password
  validates :shop, uniqueness: true
  before_save :check_credentials, unless: "Sinatra::Base.test?"

  def self.service_name
    "my-fulfillment-service"
  end

  def fulfill(order, fulfillment)
    response = instance.fulfill(
      order.id,
      address(order.shipping_address),
      line_items(order, fulfillment),
      fulfill_options(order, fulfillment)
    )

    response.success?
  end

  def fetch_stock_levels(options={})
    instance.fetch_stock_levels(options)
  end

  def fetch_tracking_numbers(order_ids)
    instance.fetch_tracking_numbers(order_ids)
  end

  private

  def instance
    @instance ||= ActiveMerchant::Fulfillment::ShipwireService.new(
      :login => username,
      :password => password,
      :test => true,
      :include_empty_stock => true
    )
  end

   def address(address_object)
    {:name     => address_object.name,
     :company  => address_object.company,
     :address1 => address_object.address1,
     :address2 => address_object.address2,
     :phone    => address_object.phone,
     :city     => address_object.city,
     :state    => address_object.province_code,
     :country  => address_object.country_code,
     :zip      => address_object.zip}
  end

  def line_items(order, fulfillment)
    fulfillment.line_items.map do |line|
      { sku: line.sku,
        quantity: line.quantity,
        description: line.title,
        value: line.price,
        currency_code: order.currency
      } if line.quantity > 0
    end.compact
  end

  def fulfill_options(order, fulfillment)
    {:order_date      => order.created_at,
     :comment         => 'Thank you for your purchase',
     :email           => order.email,
     :tracking_number => fulfillment.tracking_number,
     :warehouse       => '00', # shipwire specific
     :shipping_method => "1D", # order.shipping_lines.first.code, also shipwire specific
     :note            => order.note}
  end

  def check_credentials
    unless instance.valid_credentials?
      errors.add(:password, "Must have valid shipwire credentials to use the services provided by this app.")
      return false
    end
  end

end
