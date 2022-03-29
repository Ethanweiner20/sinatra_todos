require "sinatra"
require "sinatra/reloader"
require "tilt/erubis"

get "/" do
  redirect "/lists"
end

get "/lists" do
  # Temporary Example Data
  @lists = [
    {
      name: "Lunch Groceries",
      todos: ["Cheese", "Bread"]
    },
    {
      name: "Dinner Groceries",
      todos: ["Cheese", "Bread", "Spaghetti"]
    }
  ]

  erb :lists
end
