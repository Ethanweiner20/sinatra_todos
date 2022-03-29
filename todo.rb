require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# CONFIGURATION

configure do
  enable :sessions

  # Disables random secret creation by Sinatra; enables persistent secret
  set :session_secret, 'secret'
end

# filters

before do
  # Initialize the empty session
  session[:lists] ||= []
end

# ROUTES

get "/" do
  redirect "/lists"
end

# Viewing Lists

get "/lists" do
  @lists = session[:lists]
  erb :lists
end

# Adding Lists

get "/lists/new" do
  erb :new_list
end

post "/lists" do
  session[:lists] << { name: params["list-name"], todos: [] }
  redirect "/lists"
end