$(document).ready(function() {
    if ($('body').hasClass('root')) {
        $(function () {
            $('#container').highcharts({
                chart: {
                    zoomtype: 'x'
                },
                title: {
                    text: 'Number of People Imprisoned in Azerbaijan for Political Purposes'
                },
                xAxis: {
                    categories: 'datetime'

                },
                yAxis: {
                    title: {
                        text: 'Number of Imprisoned'
                    }
                },
                series: [{
                    name: 'Jane',
                    data: [1, 0, 4]
                }, {
                    name: 'John',
                    data: [5, 7, 3]
                }]
            });
        });
    }
});