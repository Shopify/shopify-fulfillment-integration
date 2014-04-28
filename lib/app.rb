require './lib/base'
require './lib/models/fulfillment_service'
require './lib/fulfillment_service_routes'

class SinatraApp < ShopifyApp

  # Home page
  get '/' do
    shopify_session do |shop_name|
      @shop = Shop.find_by(:name => shop_name)
      @service = FulfillmentService.find_by(shop_id: @shop.id)

      # this is quick and dirty - this should be paginated etc.
      @products = ShopifyAPI::Variant.find(:all).select{ |variant| variant.fulfillment_service == FulfillmentService.service_name }

      erb :home
    end
  end

  # /fulfill
  # reciever of fulfillments/create webhook
  # if the fulfillment uses this service then
  # acquire and parse the data we need to forward
  # the request to the fulfillment service. Send the request
  # to the other service and respond to Shopify completing the
  # fulfillment.
  #
  post '/fulfill.json' do
    webhook_session do |shop, params|
      return status 200 unless params["service"] == FulfillmentService.service_name

      order = ShopifyAPI::Order.find(params["order_id"])
      fulfillment = ShopifyAPI::Fulfillment.find(params["id"], :params => {:order_id => params["order_id"]})

      service = FulfillmentService.find_by(shop_id: shop.id)

      if service.fulfill(order, fulfillment)
        fulfillment.complete
      end
    end
  end

  # /fetch_stock
  # Listen for a request from Shopify
  # When a request is recieved make a request to fulfillment service
  # Parse response from fulfillment service
  # Respond to Shopify
  #
  # Example of a Shopify request:
  # https://myapp.com/fetch_stock?sku=123&shop=testshop.myshopify.com
  #
  get '/fetch_stock.json' do
    fulfillment_session do |service|
      sku = params["sku"]
      response = service.fetch_stock_levels(sku: sku)
      stock_levels = response.stock_levels

      content_type :json
      stock_levels.to_json
    end
  end

  # /fetch_tracking_numbers
  # Listen for a request from Shopify
  # When a request is recieved make a request to fulfillment service
  # Parse response from fulfillment service
  # Respond to Shopify
  #
  # Example of a Shopify request:
  # http://myapp.com/fetch_tracking_numbers?order_ids[]=1&order_ids[]=2&order_ids[]=3
  #
  get '/fetch_tracking_numbers.json' do
    fulfillment_session do |service|
      order_ids = params["order_ids"]
      response = service.fetch_tracking_numbers(order_ids)
      tracking_numbers = response.tracking_numbers

      content_type :json
      tracking_numbers.to_json
    end
  end

  private

  def install
    shopify_session do
      params = YAML.load(File.read("config/app.yml"))

      fulfillment_service = ShopifyAPI::FulfillmentService.new(params["service"])
      fulfillment_webhook = ShopifyAPI::Webhook.new(params["fulfillment_webhook"])
      uninstall_webhook = ShopifyAPI::Webhook.new(params["uninstall_webhook"])

      # create the fulfillment service if not present
      unless ShopifyAPI::FulfillmentService.find(:all).include?(fulfillment_service)
        fulfillment_service.save
      end

      # create the fulfillment webhook if not present
      unless ShopifyAPI::Webhook.find(:all).include?(fulfillment_webhook)
        fulfillment_webhook.save
      end

      # create the uninstall webhook if not present
      unless ShopifyAPI::Webhook.find(:all).include?(uninstall_webhook)
        uninstall_webhook.save
      end
    end
    redirect '/'
  end

  def uninstall
    # webhook_session do |shop, params|
    #   # remove any dependent models
    #   service = FulfillmentService.where(shop_id: shop.id).destroy_all
    #   # remove shop model
    #   shop.destroy
    # end
  end

  def fulfillment_session(&blk)
    shop_name = params["shop"]
    shop = Shop.find_by(:name => shop_name)
    if shop.present?
      service = FulfillmentService.find_by(shop_id: shop.id)
      if service.present?
        yield service
      end
    end
  end

end
