require "test_helper"
require './lib/jobs/fulfillment_job'

class FulfillmentJobTest < Test::Unit::TestCase

  def test_fulfillment_job
    shop_name = "testshop.myshopify.com"
    fulfillment_webhook = load_fixture 'fulfillment_webhook.json'
    params = ActiveSupport::JSON.decode(fulfillment_webhook)

    shop_url = "https://testshop.myshopify.com/admin"
    token = 'fake_token'
    fake "#{shop_url}/orders/450789469.json", :body => load_fixture('order.json')
    fake "#{shop_url}/orders/450789469/fulfillments/255858046.json", :body => load_fixture('fulfillment.json')

    FulfillmentService.any_instance.expects(:fulfill).returns(true)
    ShopifyAPI::Fulfillment.any_instance.expects(:complete).returns(true)

    FulfillmentJob.perform(shop_name, token, params)
  end

end
