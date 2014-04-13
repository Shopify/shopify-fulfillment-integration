require "sinatra/activerecord/rake"
require "./app"

task :server do
  api_key = `sed -n '1p' .env`
  secret = `sed -n '2p' .env`

  `export SHOPIFY_API_KEY=#{api_key}`
  `export SHOPIFY_SHARED_SECRET=#{secret}`

  SinatraApp.run!
end

task :creds2heroku do
  Bundler.with_clean_env {
    api_key = `sed -n '1p' .env`
    secret = `sed -n '2p' .env`
    `heroku config:set #{api_key}`
    `heroku config:set #{secret}`
  }
end
