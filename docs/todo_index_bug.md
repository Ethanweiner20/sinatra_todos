# Todo Index Bug

- **Problem**: When we delete an element asynchronously, the actions for the completion forms remain the same, which will now point to the wrong identifier (index) for the todo
- **Solution**: Add unique identifiers for each todo such that we aren't relying on index-based behavior
  - **Bad Solution**: Try to update the action of each element
