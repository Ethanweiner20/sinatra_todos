# Todo Tracker Application

_Purpose of this Document_: List requirements, ideas, & planning for the application

## Requirements

- /lists
  - Lists all todolists
    - Lists # of todos in list
- /lists/:list
  - Add todos
  - For each todo: Name, check/uncheck, delete
  - Functions: Complete All, Edit List
- /lists/:list/edit
  - Editing list/name
- Alerts/success messages
- Error handling
  - Input validation (between 1-200 chars)
    - Form validation
    - Path validation (valid list ids)
