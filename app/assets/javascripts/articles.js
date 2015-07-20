$(document).ready(function() {
    if ($('form.article').length) {
        loadTinymce();
    }
});

function article_incident_counts_chart() {
    $.ajax({
        url: gon.article_incident_counts_articles_path,
        async: true,
        dataType: 'json',
        success: function (response) {
            var text = response.text
            var data = response.data

            $('#top-10-charge-counts').highcharts({
                chart: {
                    type: 'bar'
                },
                title: {
                    text: text.title,
                    useHTML: true
                },
                subtitle: {
                    text: '<a href="' + text.articles_path + '">' + text.explore_charges + '</a>',
                    useHTML: true
                },
                yAxis: {
                    title: {
                        text: text.y_axis_label
                    },
                    allowDecimals: false
                },
                xAxis: {
                    categories: data,
                    title: {
                        text: text.x_axis_label
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
                      var info = this.point.summary;

                      return info;
                    },
                    useHTML: true,
                    style: { padding: '1px' }
                },
                series: [{
                    name: text.y_axis_label,
                    showInLegend: false,
                    data: data
                }]
            });
        }
    });
}
