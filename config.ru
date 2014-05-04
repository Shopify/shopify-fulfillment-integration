require './lib/app'
require 'resque/server'

AUTH_PASSWORD = ENV['RESQUE_PASSWORD']
if AUTH_PASSWORD
  Resque::Server.use Rack::Auth::Basic do |username, password|
    password == AUTH_PASSWORD
  end
end

run Rack::URLMap.new \
  '/'       => SinatraApp,
  '/resque' => Resque::Server.new
