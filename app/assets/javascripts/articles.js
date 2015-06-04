$(document).ready(function() {
    if ($('body').hasClass('articles')) {
        loadTinymce();
    }
});

var article_incident_counts_chart = function() {
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
                    formatter: function() { return 'Article <strong>#' + this.point.number + '</strong> (' + this.point.code + ' Criminal Code) has been<br/>used to sentence political prisoners <strong>' + this.point.y + '</strong> times.';
                    }
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
