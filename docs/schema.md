# Schema

Lists

- Name (unique)

Todos

- Name
- IsCompleted (default false)
- List (required)

Relationships: List -> todos = One-to-many (a todo must have a list)

_Note_: There is no "users" entity. For this database, we are storing a separate list of todos per user.
