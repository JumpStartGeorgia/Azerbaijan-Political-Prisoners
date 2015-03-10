$(document).ready(function() {
    if ($('body').hasClass('root')) {

        // The data for this graph is not complete, so the graph is erroneous until the data is updated. The prisoners in the database currently only include those who were imprisoned as of August 2014. Any prisoners who were arrested and released after the starting date of this timeline and before August 2014 would not be reflected in this data.
//        $.ajax({
//            url: 'chart_data/imprisoned_count_timeline.json',
//            async: true,
//            dataType: 'json',
//            success: function (response) {
//                $(function () {
//                    $('#imprisoned-count-timeline').highcharts({
//                        chart: {
//                            zoomType: 'x',
//                            resetZoomButton: {
//                                position: {
//                                    align: 'left',
//                                    verticalAlign: 'top',
//                                    x: 10,
//                                    y: 10
//                                }
//                            }
//                        },
//                        title: {
//                            text: 'Number of Political Prisoners in Azerbaijan from 2007 through Today'
//                        },
//                        subtitle: {
//                            text: document.ontouchstart === undefined ?
//                                'Click and drag in the plot area to zoom in' :
//                                'Pinch the chart to zoom in'
//                        },
//                        xAxis: {
//                            type: 'datetime',
//                            minRange: 14 * 24 * 3600000 // fourteen days
//                        },
//                        yAxis: {
//                            title: {
//                                text: 'Number of Political Prisoners'
//                            },
//                            min: 0
//                        },
//                        series: [{
//                            name: 'Number of Political Prisoners',
//                            showInLegend: false,
//                            data: response.data
//                        }]
//                    });
//                });
//            }
//        });

        $.ajax({
            url: 'chart_data/highest_incident_counts_chart.json',
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
                        }
                    },
                    xAxis: {
                        categories: response.article_numbers,
                        title: {
                            text: 'Article Number'
                        }
                    },
                    tooltip: {
                        formatter: function() { return '' +
                            'Number of Sentences: ' + this.point.y + '<br/>' +
                            'Criminal Code: ' + this.point.criminal_code
                        }
                    },
                    series: [{
                        name: 'Number of Sentences',
                        showInLegend: false,
                        data: response.series_data
                    }]
                });
            }
        });
    }
});