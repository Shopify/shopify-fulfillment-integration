require './lib/base'
require './lib/models/fulfillment_service'

class FulfillmentJob
  @queue = :default

  def self.perform(params, shop_name)
    puts "1"
    return unless params["service"] == FulfillmentService.service_name

    puts "2"
    shop = Shop.find_by(:name => shop_name)

    puts "3"
    if shop.present?
      puts "4"
      api_session = ShopifyAPI::Session.new(shop_name, shop.token)
      puts "5"
      ShopifyAPI::Base.activate_session(api_session)
      puts "6"
      order = ShopifyAPI::Order.find(params["order_id"])
      puts "7"
      fulfillment = ShopifyAPI::Fulfillment.find(params["id"], :params => {:order_id => params["order_id"]})
      puts "8"
      service = FulfillmentService.find_by(shop_id: shop.id)
      puts "9"
      if service.fulfill(order, fulfillment)
        fulfillment.complete
      end
    end
  end

end
