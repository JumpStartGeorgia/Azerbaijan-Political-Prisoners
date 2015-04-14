$(document).ready(function() {
    if ($('body').hasClass('root')) {
        $.ajax({
            url: 'chart_data/imprisoned_count_timeline',
            async: true,
            dataType: 'json',
            success: function (response) {
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
                            text: 'Number of Political Prisoners in Azerbaijan from 2007 through Today - <strong>DATA INCOMPLETE<sup>*</sup></strong>',
                            useHTML: true
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
                            min: 0,
                            allowDecimals: false
                        },
                        series: [{
                            name: 'Number of Political Prisoners',
                            showInLegend: false,
                            data: response.data
                        }]
                    });
                });
            }
        });

        $.ajax({
            url: 'chart_data/prison_prisoner_counts',
            async: true,
            dataType: 'json',
            success: function (response) {
                $('#prison-prisoner-counts').highcharts({
                    chart: {
                        type: 'bar'
                    },
                    title: {
                        text: 'Number of Prisoners by Prison'
                    },
                    yAxis: {
                        title: {
                            text: 'Number of Prisoners'
                        },
                        allowDecimals: false
                    },
                    xAxis: {
                        categories: response,
                        labels: {
                            formatter: function() {
                                return '<a href="' + this.value.link + '">' + this.value.name + '</a>';
                            },
                            useHTML: true
                        }

                    },
                    tooltip: {
                        formatter: function() {
                            var prisoner_count = this.point.y;
                            if ( prisoner_count == '1' ) {
                                return this.point.y + ' prisoner at ' + this.point.name
                            }
                            else {
                                return this.point.y + ' prisoners at ' + this.point.name
                            }
                        }
                    },
                    series: [{
                        name: 'Number of Prisoners',
                        showInLegend: false,
                        data: response
                    }]
                });
            }
        });

        $.ajax({
            url: 'chart_data/article_incident_counts',
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
    }
});