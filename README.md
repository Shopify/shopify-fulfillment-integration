Fulfillment_Integration
=======================

A simple sinatra web app demonstrating how to integrate an existing fulfillment service with an api into Shopify using the [Shopify Fulfillment Service API](http://docs.shopify.com/api/fulfillmentservice) and the [Shopify Embedded App SDK](http://docs.shopify.com/embedded-app-sdk).

Check out the code in `lib/app.rb` and read the [docs](http://docs.shopify.com/api/fulfillmentservice) to understand how the app works.

This app is built using the shopify-sinatra-app framework, take a look at the framework readme for information about developing locally and deploying to Heroku.

This particular app integrates with [Shipwire](http://www.shipwire.com/)

After you have the app running visit the install page (located at your url + '/install') and install the app on your Shopify test store. Then you will need to add your Shipwire Credentials - you can create a Shipwire developer account which will let you make requests in `test` mode - the app is configured for this by default. In test mode Shipwire will always return the same data regardless of what is in the request. Therefore when creating a product to use the custom fulfillment app always use either `GD802-024` or `GD201-500` for the SKU.

Running Tests
-------------

First run the rake command `test:prepare` which will initialize the test database. Then simply run:

```
rake test
```
