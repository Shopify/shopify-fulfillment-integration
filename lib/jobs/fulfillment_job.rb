require './lib/base'
require './lib/models/fulfillment_service'

class FulfillmentJob
  @queue = :default

  def self.perform(params, shop_name)
    return unless params["service"] == FulfillmentService.service_name

    shop = Shop.find_by(:name => shop_name)

    if shop.present?
      api_session = ShopifyAPI::Session.new(shop_name, shop.token)
      ShopifyAPI::Base.activate_session(api_session)

      order = ShopifyAPI::Order.find(params["order_id"])
      fulfillment = ShopifyAPI::Fulfillment.find(params["id"], :params => {:order_id => params["order_id"]})

      service = FulfillmentService.find_by(shop_id: shop.id)

      if service.fulfill(order, fulfillment)
        fulfillment.complete
      end
    end
  end

end
