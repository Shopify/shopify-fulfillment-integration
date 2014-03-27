require 'shopify_api'
require 'highline/import'
require 'pry'

shopname = ask("Enter your Shopify shop name: ") { |q| q.echo = true }
api_key = ask("Enter your private app API Key: ") { |q| q.echo = true }
password = ask("Enter your private app Password: ") { |q| q.echo = true }

shop_url = "https://#{api_key}:#{password}@#{shopname}.myshopify.com/admin"
puts shop_url

ShopifyAPI::Base.site = shop_url

params = YAML.load(File.read("fulfillment_service.yml"))

fulfillment_service = ShopifyAPI::FulfillmentService.new(params["service"])

if fulfillment_service.save
  puts "new fulfillment service added successfuly"
else
  puts fulfillment_service.errors
end

webhook = ShopifyAPI::Webhook.new
webhook.topic = "fulfillments/create"
webhook.address = fulfillment_service.callback_url + "/fulfill.json"
webhook.format = "json"

if webhook.save
  puts "new webhook added successfuly"
else
  puts webhook.errors
end
