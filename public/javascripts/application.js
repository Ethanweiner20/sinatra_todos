$(function () {
  // Require confirmation for all deletions

  // $("form.delete").submit(function () {
  //   return confirm("Are you sure?"); // Returns true only if confirmed
  // });

  $("form.delete").submit(function (event) {
    event.preventDefault();
    event.stopPropagation();

    if (confirm("Are you sure?")) this.submit();
  });
});
