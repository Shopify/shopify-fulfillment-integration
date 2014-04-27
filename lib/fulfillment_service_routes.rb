require './lib/base'
require './lib/models/fulfillment_service'

class SinatraApp < ShopifyApp

  post '/fulfillment_service' do
    shopify_session do |shop_name|
      shop = Shop.where(:name => shop_name).first
      params.merge!(shop: shop)
      service = FulfillmentService.new(params)

      if service.save
        flash[:notice] = "Credentials Saved"
      else
        flash[:error] = "Error Saving Credentials"
      end

      redirect '/'
    end
  end

  put '/fulfillment_service' do
    shopify_session do |shop_name|
      shop = Shop.find_by(:name => shop_name)
      service = FulfillmentService.find_by(shop_id: shop.id)

      if service.update_attributes(service_params(params))
        flash[:notice] = "Credentials Updated"
      else
        flash[:error] = "Error Updating Credentials"
      end
    end

    redirect '/'
  end

  private

  def service_params(params)
    params.slice("username", "password")
  end

end
