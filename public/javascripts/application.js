$(function () {
  $("form.delete").submit(function (event) {
    event.preventDefault();
    event.stopPropagation();

    const form = $(this);
    const request = $.ajax({
      url: form.attr("action"),
      method: form.attr("method"),
    });

    // Callback on response
    request.done(function (data, textStatus, jqXHR) {
      if (jqXHR.status === 204) {
        // Remove todo
        form.parent("li").remove();
      } else if (jqXHR.status === 200) {
        // Redirect to page
        document.location = data;
      }
    });
  });
});
