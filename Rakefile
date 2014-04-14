require "sinatra/activerecord/rake"
require "./app"

task :server do
  api_key = `sed -n '1p' .env`
  secret = `sed -n '2p' .env`

  ENV[api_key.split('=').first] = api_key.split('=').last.strip
  ENV[secret.split('=').first] = secret.split('=').last.strip
  # need to re load the class here somehow
  # or maybe set the API_KEY var directly ...
  SinatraApp.run!
end

task :clear_shops do
  Shop.delete_all
end

task :creds2heroku do
  Bundler.with_clean_env {
    api_key = `sed -n '1p' .env`
    secret = `sed -n '2p' .env`
    `heroku config:set #{api_key}`
    `heroku config:set #{secret}`
  }
end
