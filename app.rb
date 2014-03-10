require 'sinatra'
require "uri"
require 'net/http'

get '/' do
  "Shopify Fulfillment Integration"
end

def forward_request
  request_bin = "/132ahma1"
  uri = URI.parse("http://requestb.in" + request_bin)
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
end

get '/fetch_stock.json' do
  forward_request
end

get '/fetch_tracking_numbers.json' do
  forward_request
end
