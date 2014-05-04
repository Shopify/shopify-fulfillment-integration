Fulfillment_Integration
=======================

A simple sinatra web app demonstrating how to integrate an existing fulfillment service with an api into Shopify using the [Shopify Fulfillment Service API](http://docs.shopify.com/api/fulfillmentservice) and the [Shopify Embedded App SDK](http://docs.shopify.com/embedded-app-sdk).

Check out the code in `lib/app.rb` and read the [docs](http://docs.shopify.com/api/fulfillmentservice) to understand how the app works.

This particular app integrates with [Shipwire](http://www.shipwire.com/) In order to test/play with this app you will need to create a new application on Heroku:

```
heroku apps:create <my_fulfillment_app>
```

* note you will need a Heroku account and the Heroku toolbelt installed for your OS, check out [Getting Started with Heroku](https://devcenter.heroku.com/articles/quickstart)

You will also need to add the following (free) add-ons to your new Heroku app:

```
heroku addons:add heroku-postgresql
heroku addons:add rediscloud
```

and make sure you have at least 1 dyno for web and resque:

```
heroku scale web=1 resque=1
```

You will also need to create a Shopify Partner Account and a new application. You can make an account [here](http://www.shopify.ca/partners) and see this [tutorial](http://docs.shopify.com/api/the-basics/getting-started) for creating a new application.

After creating your new application you need to create a `.env` file and add the following variables:

```
SHOPIFY_API_KEY=<your api key>
SHOPIFY_SHARED_SECRET=<your shared secret>
SECRET=<generate a random string to encrypt credentials with>
```

The rake command `creds2heroku` will copy these env variables to your Heroku app.

You'll also want to update the `config/app.yml` file with your app url and make any other changes you want.

Now you can run the app locally using `rake server` or deploy the app to Heroku using `rake deploy`. If you run the app locally you'll need to allow running unsafe scripts in your browser due to mixed content restrictions, you can read more about this [here](http://docs.shopify.com/embedded-app-sdk/getting-started) and [here](https://developer.mozilla.org/en-US/docs/Security/MixedContent)

After you have the app running visit the install page (located at your url + '/install') and install the app on your Shopify test store. Then you will need to add your Shipwire Credentials - you can create a Shipwire developer account which will let you make requests in `test` mode - the app is configured for this by default. In test mode Shipwire will always return the same data regardless of what is in the request. Therefore when creating a product to use the custom fulfillment app always use either `GD802-024` or `GD201-500` for the SKU.

Running Tests
-------------

First run the rake command `test_prepare` which will initialize the test database. Then simply run:

```
rake test
```
