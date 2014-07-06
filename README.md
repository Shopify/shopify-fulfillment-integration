shopify-fulfillment-integration
=======================

A simple sinatra web app demonstrating how to integrate an existing fulfillment service with an API into Shopify using the [Shopify Fulfillment Service API](http://docs.shopify.com/api/fulfillmentservice) and the [Shopify Embedded App SDK](http://docs.shopify.com/embedded-app-sdk).

Check out the code in `lib/*` and read the [docs](http://docs.shopify.com/api/fulfillmentservice) to understand how the app works.

This app is built using the [shopify-sinatra-app](https://github.com/pickle27/shopify-sinatra-app) framework, take a look at the framework [readme](https://github.com/pickle27/shopify-sinatra-app) for information about developing locally and deploying to Heroku.

This particular app is an example integration with [Shipwire](http://www.shipwire.com/)

After you have the app running visit the install page (located at your url + '/install') and install the app on your Shopify test store. Then you will need to add your Shipwire Credentials - you can create a Shipwire developer account which will let you make requests in `test` mode - the app is configured for this by default. In test mode Shipwire will always return the same data regardless of what is in the request. Therefore when creating a product to use the custom fulfillment app always use either `GD802-024` or `GD201-500` for the SKU.

If you use this template as a starting point for building an integration it is strongly recommended that you follow a similar pattern used here and add the specific logic for formating and parsing the requests to the [Active Fulfillment library](https://github.com/Shopify/active_fulfillment).

Running Tests
-------------

First run the rake command `test:prepare` which will initialize the test database. Then simply run:

```
rake test
```
