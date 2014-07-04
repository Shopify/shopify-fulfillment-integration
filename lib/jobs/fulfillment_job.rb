require 'sinatra/shopify-sinatra-app'
require './lib/models/fulfillment_service'

class FulfillmentJob
  @queue = :default

  def self.perform(shop_name, token, params)
    return unless params["service"] == FulfillmentService.service_name

    api_session = ShopifyAPI::Session.new(shop_name, token)
    ShopifyAPI::Base.activate_session(api_session)

    order = ShopifyAPI::Order.find(params["order_id"])
    fulfillment = ShopifyAPI::Fulfillment.find(params["id"], :params => {:order_id => params["order_id"]})

    service = FulfillmentService.find_by(shop: shop_name)

    if service.fulfill(order, fulfillment)
      fulfillment.complete
    end
  end

end
