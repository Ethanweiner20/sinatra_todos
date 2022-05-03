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

  private

  # Assumes that each item in `items` has an `:id` attribute
  def next_id(items)
    max_id = items.map { |item| item[:id] }.max || 0
    max_id + 1
  end
end
