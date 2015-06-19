$(document).ready(function() {
  // Run only on home page
  if ($('body').hasClass('root index')) {
    homePage();
  }
});

function homePage() {
  $(window).resize(function() {
    loadCharts();
  })

  loadCharts();
}

function loadCharts() {
  imprisoned_count_timeline();
  prison_prisoner_counts_chart();
  article_incident_counts_chart();
}
