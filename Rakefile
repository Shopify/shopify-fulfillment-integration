task :server do
  `foreman start`
end

task :creds2heroku do
  Bundler.with_clean_env {
    api_key = `sed -n '1p' .env`
    secret = `sed -n '2p' .env`
    `heroku config:set #{api_key}`
    `heroku config:set #{secret}`
  }
end
