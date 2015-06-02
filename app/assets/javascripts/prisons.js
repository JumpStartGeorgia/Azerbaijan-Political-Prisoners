$(document).ready(function() {
    if ($('body').hasClass('prisons')) {
        loadTinymce();
    }
});

var prison_prisoner_counts_chart = function() {
    $.ajax({
        url: 'prisons/prison_prisoner_counts',
        async: true,
        dataType: 'json',
        success: function (response) {
            $('#prison-prisoner-counts').highcharts({
                chart: {
                    type: 'bar'
                },
                title: {
                    text: 'Ten Prisons with the Most Political Prisoners'
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
                        useHTML: true,
                        step: 1,
                        style: { 'textAlign': 'right' }
                    }

                },
                tooltip: {
                    formatter: function() {
                        var prisoner_count = this.point.y;
                        if ( prisoner_count == '1' ) {
                            return 'There is <strong>' + this.point.y + '</strong> political prisoner at <strong>' + this.point.name + '</strong>'
                        }
                        else {
                            return 'There are <strong>' + this.point.y + '</strong> political prisoners at <strong>' + this.point.name + '</strong>'
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
};
