$(document).ready(function() {
    if ($('body').hasClass('articles')) {
        loadTinymce();
    }
});

var article_incident_counts_chart = function() {
    $.ajax({
        url: 'data/article_incident_counts',
        async: true,
        dataType: 'json',
        success: function (response) {
            $('#top-10-charge-counts').highcharts({
                chart: {
                    type: 'bar'
                },
                title: {
                    text: 'The Ten Charges Used Most Often to Sentence Political Prisoners'
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
                        useHTML: true
                    }
                },
                tooltip: {
                    formatter: function() { return '' +
                        'Number of Sentences: ' + this.point.y + '<br/>' +
                        'Criminal Code: ' + this.point.code;
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