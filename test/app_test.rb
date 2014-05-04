require "test_helper"
require "./lib/app"

class AppTest < Test::Unit::TestCase

  def app
    SinatraApp
  end

  def test_fulfill
    shop_name = "testshop.myshopify.com"
    fulfillment_webhook = load_fixture 'fulfillment_webhook.json'
    params = ActiveSupport::JSON.decode(fulfillment_webhook)

    SinatraApp.any_instance.expects(:verify_shopify_webhook).returns(true)
    Resque.expects(:enqueue).with(FulfillmentJob, params, shop_name).returns(true)

    post '/fulfill.json', fulfillment_webhook, 'HTTP_X_SHOPIFY_SHOP_DOMAIN' => shop_name

    assert last_response.ok?
  end

  def test_fetch_stock
    response = stub(stock_levels: {'123' => 10})
    FulfillmentService.any_instance.expects(:fetch_stock_levels).returns(response)

    get '/fetch_stock.json', :shop => 'testshop.myshopify.com', :sku => '123'

    assert last_response.ok?
    assert_equal({'123' => 10}.to_json, last_response.body)
  end

  def test_fetch_tracking_numbers
    response = stub(tracking_numbers: {'#1001' => '123456789'})
    FulfillmentService.any_instance.expects(:fetch_tracking_numbers).returns(response)

    get '/fetch_tracking_numbers.json', :shop => 'testshop.myshopify.com', :order_ids => ['#1001']

    assert last_response.ok?
    assert_equal({'#1001' => '123456789'}.to_json, last_response.body)
  end

  def test_fetch_tracking_numbers_multiple
    response = stub(tracking_numbers: {'#1001' => '123456789', '#1002' => '987654321'})
    FulfillmentService.any_instance.expects(:fetch_tracking_numbers).returns(response)

    get '/fetch_tracking_numbers.json', :shop => 'testshop.myshopify.com', :order_ids => ['#1001', '#1002']

    assert last_response.ok?
    assert_equal({'#1001' => '123456789', '#1002' => '987654321'}.to_json, last_response.body)
  end

end


