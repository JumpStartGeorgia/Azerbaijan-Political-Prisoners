$(document).ready(function() {
    if ($('body').hasClass('root')) {
        imprisoned_count_timeline();
        prison_prisoner_counts_chart();
        article_incident_counts_chart();
    }
});