require 'bundler/setup'
Bundler.require

log = []

# home page
get '/' do
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
