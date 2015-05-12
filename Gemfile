source 'https://rubygems.org'
ruby "2.1.5"

gem 'active_fulfillment'

gem 'omniauth-shopify-oauth2', '~> 1.1.8'
gem 'shopify_api', '~> 4.0.2'
gem 'shopify-sinatra-app', '~> 0.1.0'

gem 'foreman'
gem 'rake'

group :production do
  gem 'pg'
end

group :development do
  gem 'sqlite3'
  gem 'rack-test'
  gem 'fakeweb'
  gem 'mocha', require: false
  gem 'pry'
  gem 'byebug'
end
