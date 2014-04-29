require "sinatra/activerecord/rake"
require 'rake/testtask'
require "./lib/app"

task :server do
  SinatraApp.run!
end

task :deploy do
  pipe = IO.popen("git push heroku master --force")
  while (line = pipe.gets)
    print line
  end
end

task :test_prepare do
  `RACK_ENV=test rake db:create`
  `RACK_ENV=test rake db:migrate`
  `RACK_ENV=test rake db:seed`
end

task :test do
  Rake::TestTask.new do |t|
    t.pattern = 'test/*_test.rb'
    t.libs << 'test'
    t.verbose = true
  end
end

task :clear do
  Rake::Task["clear_shops"].execute
  Rake::Task["clear_services"].execute
end

task :clear_shops do
  Shop.delete_all
end

task :clear_services do
  FulfillmentService.delete_all
end

task :creds2heroku do
  Bundler.with_clean_env {
    api_key = `sed -n '1p' .env`
    shared_secret = `sed -n '2p' .env`
    secret = `sed -n '3p' .env`
    `heroku config:set #{api_key}`
    `heroku config:set #{shared_secret}`
    `heroku config:set #{secret}`
  }
end
