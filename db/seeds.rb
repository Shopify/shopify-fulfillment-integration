shop = Shop.create(name: 'testshop.myshopify.com', token: 'token')
service = FulfillmentService.create(shop: shop, username: 'username', password: 'password')
