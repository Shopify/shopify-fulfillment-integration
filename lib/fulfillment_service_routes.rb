require 'sinatra/shopify-sinatra-app'
require './lib/models/fulfillment_service'

class SinatraApp < Sinatra::Base

  post '/fulfillment_service' do
    shopify_session do
      params.merge!(shop: current_shop_name)
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
    shopify_session do
      service = FulfillmentService.find_by(shop: current_shop)

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
