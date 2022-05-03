require "pg"

class DatabasePersistence
  def initialize(logger)
    @db = if Sintra::Base.production?
            PG.connect(ENV['DATABASE_URL'])
          else
            PG.connect(dbname: 'todos')
          end
    @logger = logger
  end

  # Perform and log a query

  def query(statement, *params)
    @logger.info "#{statement}: #{params}"
    db.exec_params(statement, params)
  end

  # List storage

  def all_lists
    sql = "SELECT * FROM lists;"
    result = query(sql)

    result.map do |tuple|
      list_id = tuple["id"].to_i
      todos = find_todos(list_id)
      { id: list_id, name: tuple["name"], todos: todos }
    end
  end

  def find_list(id)
    sql = "SELECT * FROM lists WHERE id = $1;"
    result = query(sql, id)
    tuple = result.first
    list_id = tuple["id"].to_i
    todos = find_todos(list_id)

    { id: tuple["id"].to_i, name: tuple["name"], todos: todos }
  end

  def create_list(name)
    sql = "INSERT INTO lists (name) VALUES ($1);"
    query(sql, name)
  end

  def delete_list(id)
    query("DELETE FROM todos WHERE list_id = $1", id)
    query("DELETE FROM lists WHERE id = $1", id)
  end

  def update_list_name(id, new_name)
    query("UPDATE lists SET name = $1 WHERE id = $2", new_name, id)
  end

  # Managing todos

  def create_todo(list_id, todo_name)
    sql = "INSERT INTO todos (name, list_id) VALUES ($1, $2)"
    query(sql, todo_name, list_id)
  end

  def delete_todo(list_id, todo_id)
    sql = "DELETE FROM todos WHERE id = $1 AND list_id = $2"
    query(sql, todo_id, list_id)
  end

  def complete_todos(list_id)
    sql = "UPDATE todos SET completed = true WHERE list_id = $1"
    query(sql, list_id)
  end

  def set_todo_status(list_id, todo_id, new_status)
    sql = "UPDATE todos SET completed = $1 WHERE id = $2 AND list_id = $3"
    query(sql, new_status, todo_id, list_id)
  end

  def disconnect
    db.close
  end

  private

  attr_reader :db

  def find_todos(list_id)
    sql = "SELECT * FROM todos WHERE list_id = $1"
    result = query(sql, list_id)
    result.map do |tuple|
      {
        id: tuple["id"].to_i,
        name: tuple["name"],
        completed: tuple["completed"] == 't'
      }
    end
  end
end
