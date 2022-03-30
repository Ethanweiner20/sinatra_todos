require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

# CONFIGURATION

configure do
  enable :sessions

  # Disables random secret creation by Sinatra; enables persistent secret
  set :session_secret, 'secret'
end

MESSAGES = {
  list_created: "The list has been created.",
  invalid_list_name: "List name must be between 1 and 100 characters.",
  not_unique: "The list name must be unique."
}

# FILTERS

before do
  # Initialize the empty session
  session[:lists] ||= []
end

# HELPERS

# list_name_error: String -> Error?
# Returns an error symbol if the list name is invalid, otherwise returns nil
def list_name_error(name)
  if !valid_size?(name)
    :invalid_list_name
  elsif !unique?(name)
    :not_unique
  end
end

def valid_size?(name)
  name.length.between?(1, 100)
end

def unique?(name)
  list_names = session[:lists].map { |list| list[:name] }
  !list_names.include?(name)
end

def set_flash(message, type)
  session[:flash] = { message: MESSAGES[message], type: type }
end

# ROUTES

get "/" do
  redirect "/lists"
end

# View list of lists
get "/lists" do
  @lists = session[:lists]
  erb :lists
end

# Render new list form
get "/lists/new" do
  erb :new_list
end

# Add a new list
post "/lists" do
  list_name = params["list-name"].strip
  error = list_name_error(list_name)

  if error
    set_flash(error, :error)
    erb :new_list
  else
    session[:lists] << { name: list_name, todos: [] }
    set_flash(:list_created, :success)
    redirect "/lists"
  end
end
