Fulfillment_Integration
=======================

A simple sinatra web app demonstrating how to integrate an existing fulfillment service with an api into Shopify.

Usage
-----

Clone/Fork this repo and optionally rename it after the fulfillment service you are working with. 

Modify the `fetch_stock` and `fetch_tracking_numbers` method to forward the request from Shopify to your fulfillment service's API. For bonus points build the handling of making and parsing requests to your fulfillment service in (ActiveFulfillment)[https://github.com/Shopify/active_fulfillment] and use then use it here.

Create a new app on Heroku:
  ```heroku apps:create name```

Deploy to Heroku
  ```git push heroku master```

Add your new fulfillment service to Shopify using the (ShopifyAPI Gem)[https://github.com/Shopify/shopify_api]. You'll also need to create a new
private app for you Shopify store see (here)[http://docs.shopify.com/api/tutorials/creating-a-private-app] for a tutorial.
  
  ```ruby
  shop_url = "https://#{api_key}:#{pwd}@shopname.myshopify.com/admin"
  ShopifyAPI::Base.site = shop_url

  fulfillment_service = ShopifyAPI::FulfillmentService.new(...)
  fulfillment_service.save
  ```

You can also use and modify the `install.rb` script in this repo to help create the new fulfillment service.

The last step is to update the desired product variants to be fulfilled with your newly integrated fulfillment service.
