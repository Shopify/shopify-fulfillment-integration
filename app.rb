require 'sinatra'
require "uri"
require 'net/http'
require 'json'

log = []

# home page
get '/' do
  erb :index, :locals => {:log => log} 
end

# fetch_stock endpoint
get '/fetch_stock.json' do
  forward_request
end

# fetch_tracking_numbers endpoint
get '/fetch_tracking_numbers.json' do
  forward_request
end

def forward_request
  request_bin = "/132ahma1"
  uri = URI.parse("http://requestb.in" + request_bin)
  uri.query = URI.encode_www_form(params)
  response = Net::HTTP.get_response(uri)
end

# Log the request
before '/fetch*' do
  log << "Request: #{request.fullpath}"
end

# Log the response
after '/fetch*' do
  log << "Response: #{response.status} #{response.body}"
end
