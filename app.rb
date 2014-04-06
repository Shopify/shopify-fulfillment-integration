require 'bundler/setup'
Bundler.require
require 'active_support/all'

class SinatraApp < Sinatra::Base
  
  configure do
    set :sessions, true
    set :inline_templates, true
  end

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

  # Home page
  get '/' do
    erb :install
  end

  # Session
  post '/install' do
    authenticate
  end

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



  # App

  # logs page
  log = []

  get '/logs' do
    log = log[0..100] if log.size > 100
    erb :index, :locals => {:log => log.reverse} 
  end

  # /fulfill
  # reciever of fulfillments/create webhook
  post '/fulfill.json' do
    log << "[#{Time.now}] Post: #{request.fullpath}"
    status 404
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
    sku = params["sku"]
    shop = params["shop"]

    content_type :json
    { sku => 11 }.to_json
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
    order_ids = params["order_ids"]
    tracking_numbers = Hash[order_ids.map {|x| [x, "12345"]}]

    content_type :json
    { "tracking_numbers" => tracking_numbers,
      "message" => "Successfully received the tracking numbers",
      "success" => true
    }.to_json
  end

  # Log the request
  before '/fetch*' do
    log << "[#{Time.now}] Request: #{request.fullpath}"
  end

  # Log the response
  after '/fetch*' do
    log << "[#{Time.now}] Response: #{response.status} #{response.body}"
  end
end

SinatraApp.run!
