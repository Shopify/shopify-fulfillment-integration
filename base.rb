require 'sinatra/base'
require 'active_support/all'
require 'omniauth-shopify-oauth2'
require 'shopify_api'

class ShopifyApp < Sinatra::Base
  if Sinatra::Base.development?
    set :port, 5000
  end
  
  enable :inline_templates

  API_KEY = ENV['SHOPIFY_API_KEY']
  SHARED_SECRET = ENV['SHOPIFY_SHARED_SECRET']
  SCOPE = 'write_fulfillments, write_products'

  use Rack::Session::Cookie, :key => 'rack.session',
                             :path => '/',
                             :secret => 'your_secret'

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
    shop = params["shop"]
    token = request.env['omniauth.auth']['credentials']['token']

    session[:shopify] ||= {}
    session[:shopify][:shop] = shop
    session[:shopify][:token] = token

    redirect_uri = env['omniauth.params']["redirect_uri"]

    install

    redirect redirect_uri
  end

  protected

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
