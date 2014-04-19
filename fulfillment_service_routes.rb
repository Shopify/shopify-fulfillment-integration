require './base'
require './fulfillment_service'

class SinatraApp < ShopifyApp

  get '/fulfillment_service/new' do
    erb :fulfillment_service_new
  end

  post '/fulfillment_service' do
    shopify_session do
      shop_name = session[:shopify][:shop]
      shop = Shop.where(:shop => shop_name).first
      params.merge!(shop: shop)
      service = FulfillmentService.new(params)
      if service.save
        redirect '/'
      else
        redirect '/fulfillment_service/new'
      end
    end
  end

  get '/fulfillment_service/edit' do
    shopify_session do
      shop_name = session[:shopify][:shop]
      shop = Shop.find_by(:shop => shop_name)
      service = FulfillmentService.find_by(shop_id: shop.id)

      if service.present?
        @username = service.username
        erb :fulfillment_service_edit
      else
        redirect '/fulfillment_service/new'
      end
    end
  end

  put '/fulfillment_service' do
    shopify_session do
      shop_name = session[:shopify][:shop]
      shop = Shop.find_by(:shop => shop_name)
      service = FulfillmentService.find_by(shop_id: shop.id)

      if service.update_attributes(service_params(params))
        flash[:notice] = "Credentials Updated"
      else
        flash[:error] = "Error Saving Credentials"
      end
    end
  end

  private

  def service_params(params)
    params.slice("username", "password")
  end

end
