function loadCharts() {
  imprisonedCountTimeline();
  prison_prisoner_counts_chart();
  article_incident_counts_chart();
}

function homePage() {
  $(window).resize(function() {
    loadCharts();
  });

  loadCharts();
}

$(document).ready(function() {
  // Run only on home page
  if ($("body").hasClass("root index")) {
    homePage();
  }
});
