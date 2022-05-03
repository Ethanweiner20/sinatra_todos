require "sinatra"
require "sinatra/content_for"
require "sinatra/reloader" if development?
require "tilt/erubis"

# CONFIGURATION

configure do
  enable :sessions
  set :session_secret, 'secret'
end

configure do
  set :erb, escape_html: true
end

MESSAGES = {
  # Success
  list_created: "The list has been created.",
  list_edited: "The list has been updated.",
  list_deleted: "The list has been deleted.",
  todo_added: "The todo was added.",
  todo_deleted: "The todo has been deleted.",
  todo_updated: "The todo has been updated.",
  todos_completed: "All todos have been completed.",

  # Error
  invalid_list_name: "List name must be between 1 and 100 characters.",
  not_unique: "The list name must be unique.",
  invalid_todo_name: "Todo must be between 1 and 100 characters.",
  invalid_list_id: "The specified list was not found."
}

# FILTERS

before do
  # Initialize the empty session
  @storage = SessionPersistence.new(session)
end

# HELPERS

class SessionPersistence
  def initialize(session)
    @session = session
    @session[:lists] ||= []
  end

  # List storage

  def find_list(id)
    all_lists.find { |list| list[:id] == id }
  end

  def all_lists
    @session[:lists]
  end

  def create_list(name)
    @session[:lists] << { id: next_id(all_lists), name: name, todos: [] }
  end

  def delete_list(id)
    @session[:lists].delete_if { |list| list[:id] == id }
  end

  def update_list_name(id, new_name)
    list = find_list(id)
    list[:name] = new_name
  end

  # Managing todos

  def create_todo(list_id, todo_name)
    list = find_list(list_id)
    todo = { id: next_id(list[:todos]), name: todo_name, completed: false }
    list[:todos] << todo
  end

  def delete_todo(list_id, todo_id)
    list = find_list(list_id)
    list[:todos].delete_if { |todo| todo[:id] == todo_id }
  end

  def complete_todos(list_id)
    list = find_list(list_id)
    list[:todos].each { |todo| todo[:completed] = true }
  end

  def find_todo(list, todo_id)
    list[:todos].find { |todo| todo[:id] == todo_id }
  end

  def set_todo_status(list_id, todo_id, new_status)
    list = find_list(list_id)
    todo = find_todo(list, todo_id)
    todo[:completed] = new_status
  end

  # Flash storage

  def flash
    @session[:flash]
  end

  def set_flash(message, type)
    @session[:flash] = { message: MESSAGES[message], type: type }
  end

  def delete_flash
    @session.delete(:flash)
  end

  private

  # Assumes that each item in `items` has an `:id` attribute
  def next_id(items)
    max_id = items.map { |item| item[:id] }.max || 0
    max_id + 1
  end
end

def load_list(id)
  candidate_list = @storage.find_list(id)
  return candidate_list if candidate_list

  @storage.set_flash(:invalid_list_id, :error)
  redirect "/lists"
end

# list_name_error: String -> Maybe Symbol
# Returns an error symbol if the list name is invalid, otherwise returns nil
def list_name_error(name)
  if !valid_length?(name)
    :invalid_list_name
  elsif !unique_list_name?(name)
    :not_unique
  end
end

# `todo_name_error`: String -> Maybe Symbol
# Returns an error symbol if the todo name is invalid, ottherwise returns nil
def todo_name_error(name)
  if !valid_length?(name)
    :invalid_todo_name
  end
end

def valid_length?(name)
  name.length.between?(1, 100)
end

def unique_list_name?(name)
  list_names = @storage.all_lists.map { |list| list[:name] }
  !list_names.include?(name)
end

helpers do
  def list_class(list)
    "complete" if list_complete?(list)
  end

  def list_complete?(list)
    todo_count(list) > 0 && remaining_todo_count(list) == 0
  end

  def todo_count(list)
    list[:todos].count
  end

  def remaining_todo_count(list)
    list[:todos].count { |todo| !todo[:completed] }
  end

  def sort_lists(lists, &block)
    lists.partition { |list| !list_complete?(list) }.each do |partition|
      partition.each(&block)
    end
  end

  def sort_todos(todos, &block)
    todos.partition { |todo| !todo[:completed] }.each do |partition|
      partition.each(&block)
    end
  end
end

# ROUTES

get "/" do
  redirect "/lists"
end

# View list of lists
get "/lists" do
  @lists = @storage.all_lists
  erb :lists
end

# Render new list form
get "/lists/new" do
  erb :new_list
end

# View singular list
get "/lists/:list_id" do
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  erb :list
end

# Add a new list
post "/lists" do
  list_name = params["list-name"].strip

  error = list_name_error(list_name)

  if error
    @storage.set_flash(error, :error)
    erb :new_list
  else
    @storage.create_list(list_name)
    @storage.set_flash(:list_created, :success)
    redirect "/lists"
  end
end

# Render edit list form
get "/lists/:list_id/edit" do
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  erb :edit_list
end

# Edit existing list
post "/lists/:list_id" do
  list_name = params["list-name"].strip
  error = list_name_error(list_name)
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  if error
    @storage.set_flash(error, :error)
    erb :edit_list
  else
    @storage.update_list_name(@list_id, list_name)
    @storage.set_flash(:list_edited, :success)
    redirect "/lists/#{params[:list_id]}"
  end
end

# Delete an existing list
post "/lists/:list_id/destroy" do
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  @storage.delete_list(params[:list_id].to_i)
  if request.xhr?
    status 200
    "/lists"
  else
    @storage.set_flash(:list_deleted, :success)
    redirect "/lists"
  end
end

# Add a todo (to the current list)
post "/lists/:list_id/todos" do
  todo_name = params["todo-name"].strip
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  error = todo_name_error(todo_name)
  if error
    @storage.set_flash(error, :error)
    erb :list
  else
    @storage.create_todo(@list_id, todo_name)
    @storage.set_flash(:todo_added, :success)
    redirect "/lists/#{params[:list_id]}"
  end
end

# Delete a todo (from the current list)
post "/lists/:list_id/todos/:todo_id/destroy" do
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  @storage.delete_todo(@list_id, params[:todo_id].to_i)

  if request.xhr?
    status 204
  else
    @storage.set_flash(:todo_deleted, :success)
    redirect "/lists/#{params[:list_id]}"
  end
end

# Update the status of a todo
# Options: Toggle the todo OR explicitly set value of todo (better)
post "/lists/:list_id/todos/:todo_id" do
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  todo_id = params[:todo_id].to_i

  completed = params[:completed] == 'true'

  @storage.set_todo_status(@list_id, todo_id, completed)
  @storage.set_flash(:todo_updated, :success)
  redirect "/lists/#{params[:list_id]}"
end

# Complete all todos
post "/lists/:list_id/complete" do
  @list_id = params[:list_id].to_i
  @list = load_list(@list_id)

  @storage.complete_todos(@list_id)
  @storage.set_flash(:todos_completed, :success)
  redirect "/lists/#{params[:list_id]}"
end
