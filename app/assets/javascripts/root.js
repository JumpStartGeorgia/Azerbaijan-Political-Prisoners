$(document).ready(function() {
    if ($('body').hasClass('root')) {
        $.ajax({
            url: 'imprisoned_count_timeline.json',
            async: true,
            dataType: 'json',
            success: function (response) {
                console.log(response.data)

                $(function () {
                    $('#imprisoned-count-timeline').highcharts({
                        chart: {
                            zoomType: 'x',
                            resetZoomButton: {
                                position: {
                                    align: 'left',
                                    verticalAlign: 'top',
                                    x: 10,
                                    y: 10
                                }
                            }
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
                            data: response.data
                        }]
                    });
                });
            }
        });

        $('#top-10-charge-counts').highcharts({
            chart: {
                type: 'bar'
            },
            title: {
                text: 'Top 10 Charges'
            },
            yAxis: {
                title: {
                    text: 'Article Number'
                }
            },
            series: [{
                name: 'Year 1800',
                data: [107, 31, 635, 203, 2]
            }, {
                name: 'Year 1900',
                data: [133, 156, 947, 408, 6]
            }, {
                name: 'Year 2008',
                data: [973, 914, 4054, 732, 34]
            }]
        });
    }
});