$(document).ready(function() {
    if ($('body').hasClass('root')) {
        imprisoned_count_timeline();

        $.ajax({
            url: 'data/prison_prisoner_counts',
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
    }
});