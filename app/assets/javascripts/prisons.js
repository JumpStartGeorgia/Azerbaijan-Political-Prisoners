$(document).ready(function() {
    if ($('body').hasClass('prisons')) {
        loadTinymce();
    }
});

var prison_prisoner_counts_chart = function() {
    $.ajax({
        url: gon.prison_prisoner_counts_prisons_path,
        async: true,
        dataType: 'json',
        success: function (response) {
            $('#prison-prisoner-counts').highcharts({
                chart: {
                    type: 'bar'
                },
                title: {
                    text: 'Where are the prisoners being held?',
                    useHTML: true
                },
                subtitle: {
                    text: '<a href="' + gon.prisons_path + '">Click here to explore prisons</a>',
                    useHTML: true
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
