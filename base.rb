require 'sinatra/base'
require 'active_support/all'
require 'omniauth-shopify-oauth2'
require 'shopify_api'

class ShopifyApp < Sinatra::Base
  enable :sessions
  enable :inline_templates

  use OmniAuth::Builder do
    provider :shopify, 
      ENV['SHOPIFY_API_KEY'], 
      ENV['SHOPIFY_SHARED_SECRET'],

      :scope => 'write_fulfillments',

      :setup => lambda { |env| 
        params = Rack::Utils.parse_query(env['QUERY_STRING'])
        site_url = "https://#{params['shop']}"
        env['omniauth.strategy'].options[:client_options][:site] = site_url
      }
  end

  post '/install' do
    authenticate
  end

  get '/logout' do
    session[:shopify] = nil
    redirect '/'
  end

  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1><h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/auth/shopify/callback' do
    erb "<h1>#{params[:shopify]}</h1>
         <pre>#{JSON.pretty_generate(request.env['omniauth.auth'])}</pre>"
  end

  private

  def authenticate
    if shop_name = sanitize_shop_param(params)
      redirect "/auth/shopify?shop=#{shop_name}"
    else
      redirect return_address
    end
  end

  def sanitize_shop_param(params)
    return unless params[:shop].present?
    name = params[:shop].to_s.strip
    name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
    name.gsub!('https://', '').sub('http://', '')

    u = URI("http://#{name}")
    u.host.ends_with?(".myshopify.com") ? u.host : nil
  end
end
