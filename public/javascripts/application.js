// Require confirmation for all deletions
$("button[type='submit'].delete").on("click", function (e) {
  e.preventDefault();
  console.log("hello");
  return confirm("Are you sure?"); // Returns true only if confirmed
});
