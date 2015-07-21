$(document).ready(function() {
    if ($('body').hasClass('prisons')) {
        loadTinymce();
    }
});

function prison_prisoner_counts_chart() {
    $.ajax({
        url: gon.prison_prisoner_counts_prisons_path,
        async: true,
        dataType: 'json',
        success: function (response) {
            data = response.data;
            text = response.text;

            $('#prison-prisoner-counts').highcharts({
                chart: {
                    type: 'bar'
                },
                title: {
                    text: text.title,
                    useHTML: true
                },
                subtitle: {
                    text: '<a href="' + text.prisons_path + '">' + text.explore_prisons + '</a>',
                    useHTML: true
                },
                yAxis: {
                    title: {
                        text: text.number_prisoners
                    },
                    allowDecimals: false
                },
                xAxis: {
                    categories: data,
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
                        return this.point.summary;
                    },
                    useHTML: true,
                    style: { padding: '1px' }
                },
                series: [{
                    name: text.number_prisoners,
                    showInLegend: false,
                    data: data
                }]
            });
        }
    });
};
