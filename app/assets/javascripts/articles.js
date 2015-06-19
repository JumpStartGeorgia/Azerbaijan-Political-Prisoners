$(document).ready(function() {
    if ($('body').hasClass('articles')) {
        loadTinymce();
    }
});

function article_incident_counts_chart() {
    $.ajax({
        url: gon.article_incident_counts_articles_path,
        async: true,
        dataType: 'json',
        success: function (response) {
            $('#top-10-charge-counts').highcharts({
                chart: {
                    type: 'bar'
                },
                title: {
                    text: 'What are the charges?',
                    useHTML: true
                },
                subtitle: {
                    text: '<a href="' + gon.articles_path + '">Click here to explore charges</a>',
                    useHTML: true
                },
                yAxis: {
                    title: {
                        text: 'Number of Sentences'
                    },
                    allowDecimals: false
                },
                xAxis: {
                    categories: response,
                    title: {
                        text: 'Article Number'
                    },
                    labels: {
                        formatter: function() {
                            return '<a href="' + this.value.link + '">' + this.value.number + '</a>';
                        },
                        useHTML: true,
                        step: 1,
                        style: { 'textAlign': 'right' }
                    }
                },
                tooltip: {
                    formatter: function() {
                      var info = 'Article <strong>#' + this.point.number + '</strong> (' + this.point.code + ' Criminal Code) — <strong>' + this.point.y + '</strong> sentences';

                      if (this.point.description) {
                        info = info + ' — ' + this.point.description;
                      }

                      return info;
                    },
                    useHTML: true,
                    style: { padding: '1px' }
                },
                series: [{
                    name: 'Number of Sentences',
                    showInLegend: false,
                    data: response
                }]
            });
        }
    });
};
