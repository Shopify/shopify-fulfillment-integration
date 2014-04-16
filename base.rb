require 'sinatra/base'
require "sinatra/activerecord"
require 'active_support/all'
require 'omniauth-shopify-oauth2'
require 'shopify_api'

class Shop < ActiveRecord::Base
  validates_presence_of :shop, :token
end

class ShopifyApp < Sinatra::Base
  register Sinatra::ActiveRecordExtension
  set :database_file, "config/database.yml"

  SCOPE = 'write_fulfillments, write_orders, write_products'

  if Sinatra::Base.production?
    API_KEY = ENV['SHOPIFY_API_KEY']
    SHARED_SECRET = ENV['SHOPIFY_SHARED_SECRET']
    SECRET = 'my_secret'
  else
    API_KEY = `sed -n '1p' .env`.split('=').last.strip
    SHARED_SECRET = `sed -n '2p' .env`.split('=').last.strip
    SECRET = `sed -n '3p' .env`.split('=').last.strip
  end

  use Rack::Session::Cookie, :key => 'fulfillment-service.herokuapp.session',
                             :path => '/',
                             :secret => SECRET

  use OmniAuth::Builder do
    provider :shopify,
      API_KEY,
      SHARED_SECRET,

      :scope => SCOPE,

      :setup => lambda { |env|
        params = Rack::Utils.parse_query(env['QUERY_STRING'])
        site_url = "https://#{params['shop']}"
        env['omniauth.strategy'].options[:client_options][:site] = site_url
      }
  end

  ShopifyAPI::Session.setup({:api_key => API_KEY,
                             :secret => SHARED_SECRET})

  def base_url
    @base_url ||= "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}"
  end

  enable :inline_templates

  get '/install' do
    erb :session_new
  end

  get 'login' do
    erb :session_new
  end

  post '/login' do
    authenticate
  end

  get '/logout' do
    session[:shopify] = nil
    redirect '/'
  end

  get '/auth/failure' do
    erb "<h1>Authentication Failed:</h1>
         <h3>message:<h3> <pre>#{params}</pre>"
  end

  get '/auth/shopify/callback' do
    shop_name = params["shop"]
    token = request.env['omniauth.auth']['credentials']['token']

    session[:shopify] ||= {}
    session[:shopify][:shop] = shop_name
    session[:shopify][:token] = token

    redirect_uri = env['omniauth.params']["redirect_uri"]

    shop = Shop.where(:shop => shop_name)
    if shop.blank?
      Shop.create(:shop => shop_name, :token => token)
      install
    end

    redirect redirect_uri
  end

  protected

  def current_shop
    session[:shopify][:shop] if session.has_key?(:shopify)
  end

  def shopify_session(&blk)
    if !session.has_key?(:shopify)
      redirect_uri = request.env["sinatra.route"].split(' ').last
      authenticate(redirect_uri)
    end

    shop = session[:shopify][:shop]
    token = session[:shopify][:token]

    api_session = ShopifyAPI::Session.new(shop, token)
    ShopifyAPI::Base.activate_session(api_session)

    yield
  end

  def webhook_session(&blk)
    if verify_shopify_webhook
      shop_name = request.env['HTTP_X_SHOPIFY_SHOP_DOMAIN']
      shop = Shop.where(:shop => shop_name).first
      if shop.present?
        params = ActiveSupport::JSON.decode(request.body.read.to_s)
        api_session = ShopifyAPI::Session.new(shop_name, shop.token)
        ShopifyAPI::Base.activate_session(api_session)
        yield params
      end
    end
  end

  def install(shop, token)
    raise NotImplementedError
  end

  private

  def authenticate(redirect_uri = '/')
    if shop_name = sanitize_shop_param(params)
      redirect "/auth/shopify?shop=#{shop_name}&redirect_uri=#{base_url}#{redirect_uri}"
    else
      redirect '/'
    end
  end

  def verify_shopify_webhook
    data = request.body.read.to_s
    digest = OpenSSL::Digest::Digest.new('sha256')
    calculated_hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, SHARED_SECRET, data)).strip
    request.body.rewind

    calculated_hmac == request.env['HTTP_X_SHOPIFY_HMAC_SHA256']
  end

  def sanitize_shop_param(params)
    return unless params[:shop].present?
    name = params[:shop].to_s.strip
    name += '.myshopify.com' if !name.include?("myshopify.com") && !name.include?(".")
    name.gsub!('https://', '')
    name.gsub!('http://', '')

    u = URI("http://#{name}")
    u.host.ends_with?(".myshopify.com") ? u.host : nil
  end
end
