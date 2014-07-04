shop = Shop.create(name: 'testshop.myshopify.com', token: 'token')
service = FulfillmentService.create(shop: shop.name, username: 'username', password: 'password')
