// Shows and hides the loading indicator when users switch pages

$(document).on("page:fetch", function() {
  $(".loading-indicator").show();
});

$(document).on("page:change", function() {
  $(".loading-indicator").hide();
});
