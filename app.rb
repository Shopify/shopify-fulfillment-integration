require 'bundler/setup'
Bundler.require

log = []

# home page
get '/' do
  log = log[0..100] if log.size > 100
  erb :index, :locals => {:log => log.reverse} 
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
  log << "[#{Time.now}] Request: #{request.fullpath}"
end

# Log the response
after '/fetch*' do
  log << "[#{Time.now}] Response: #{response.status} #{response.body}"
end
