$(document).ready(function() {
    if ($('body').hasClass('root')) {
        $(function () {
            $('#container').highcharts({
                chart: {
                    zoomType: 'x'
                },
                title: {
                    text: 'Number of People Imprisoned in Azerbaijan for Political Purposes'
                },
                subtitle: {
                    text: document.ontouchstart === undefined ?
                        'Click and drag in the plot area to zoom in' :
                        'Pinch the chart to zoom in'
                },
                xAxis: {
                    type: 'datetime',
                    minRange: 14 * 24 * 3600000 // fourteen days
                },
                yAxis: {
                    title: {
                        text: 'Number of Political Prisoners'
                    },
                    min: 0
                },
                series: [{
                    name: 'Number of Political Prisoners',
                    data: gon.imprisoned_counts_over_time
                }]
            });
        });
    }
});