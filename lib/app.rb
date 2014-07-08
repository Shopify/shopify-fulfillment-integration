require 'sinatra/shopify-sinatra-app'
require './lib/models/fulfillment_service'
require './lib/jobs/fulfillment_job'
require './lib/fulfillment_service_routes'

class SinatraApp < Sinatra::Base
  register Sinatra::Shopify
  set :scope, 'write_fulfillments, write_orders, write_products'

  # Home page
  get '/' do
    shopify_session do
      @service = FulfillmentService.find_by(shop: current_shop_name)

      # Fetch all the variants being fulfilled with this service, note
      # you will probably want to use a different approach to get this
      # data for a production app.
      @products = []
      page = 1
      begin
        batch = ShopifyAPI::Variant.find(:all, params: {limit: 250, page: page})
        @products.concat batch.select { |variant|
          variant.fulfillment_service == FulfillmentService.service_name
        }
        page += 1
      end while batch.size > 0

      erb :home
    end
  end

  # endpoint for a products index bulk operations app link. You need to set
  # up this app link on your app in the Shopify Partner area https://app.shopify.com/services/partners
  # if you want to use this endpoint. We're going to use this endpoint to bulk set products to
  # be fulfilled and inventory managed by our service. For my example app I called this app link
  # 'fulfill with my-fulfillment-service' on Shopify.
  get '/product_app_link' do
    shopify_session do
      saved = 0
      params["ids"].each do |id|
        product = ShopifyAPI::Product.find(id)
        product.variants.each do |variant|
          variant.fulfillment_service = 'my-fulfillment-service'
          variant.inventory_management = 'my-fulfillment-service'
        end
        saved +=1 if product.save
      end

      flash[:notice] = "Updated Fulfillment Settings for #{saved} products"
      redirect '/'
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
    webhook_job(FulfillmentJob)
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

  # this method is called when the app is authorized on a Shop for
  # the first time, thus 'installed'. This methods sets up the services
  # etc. that we need on Shopify for the app to function, e.g. webhooks
  # and the fulfillment service object itself.
  def install
    shopify_session do

      fulfillment_service = ShopifyAPI::FulfillmentService.new({
        name: "my-fulfillment-service",
        handle: "my-fulfillment-service",
        callback_url: base_url,
        inventory_management: true,
        tracking_support: true,
        requires_shipping_method: false,
        response_format: "json"
      })
      fulfillment_service.save

      fulfillment_webhook = ShopifyAPI::Webhook.new({
        topic: "fulfillments/create",
        address: "#{base_url}/fulfill.json",
        format: "json"
      })
      fulfillment_webhook.save

      uninstall_webhook = ShopifyAPI::Webhook.new({
        topic: "app/uninstalled",
        address: "#{base_url}/uninstall.json",
        format: "json"
      })
      uninstall_webhook.save

    end
    redirect '/'
  end

  def uninstall
    webhook_session do |params|
      # remove any dependent models
      service = FulfillmentService.where(shop: current_shop_name).destroy
      # remove shop model
      current_shop.destroy
    end
  end

  # This is a helper method in the same vein as the webhook_session
  # method provided by shopify-sinatra-app only for handling the
  # fulfillment requests which are slighlty different than webhooks
  def fulfillment_session(&blk)
    shop_name = params["shop"]
    service = FulfillmentService.find_by(shop: shop_name)
    if service.present?
      yield service
    end
  end

end
