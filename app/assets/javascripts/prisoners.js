// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Add jQuery Select2 extra functionality to Charges multiple select
var addSelect2 = function() {
    $('select.charges_select').select2({
        placeholder: 'Select Charges',
        width: '110px'
    });

    $('select.tags_select').select2({
        placeholder: 'Select Tags',
        width: '300px'
    });
}

var addDatePickers = function() {
    $('.date_of_arrest_select, .date_of_release_select').datepicker({ dateFormat: 'yy-mm-dd'});
};

$(document).on('page:receive', function() {
    tinymce.remove();
});

$(document).ready(function() {
    if ($('body').hasClass('prisoners')) {
        addSelect2();
        loadTinymce();
        addDatePickers();

        $('#links').on('cocoon:after-insert', function(e, insertedItem) {
            addSelect2();
            loadTinymce();
            addDatePickers();
        });
    }
});

var imprisoned_count_timeline = function() {
    $.ajax({
        url: 'data/imprisoned_count_timeline',
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
                    tooltip: {
                        formatter: function() {
                            var prisoner_count = this.point.y;
                            var date = Highcharts.dateFormat('%A, %b %e, %Y', new Date(this.point.x))
                            if ( prisoner_count == '1' ) {
                                return 'There was <strong>' + prisoner_count + '</strong> political prisoner in Azerbaijan on <strong>' + date + '</strong>';
                            }
                            else {
                                return 'There were <strong>' + prisoner_count + "</strong> political prisoners in Azerbaijan on <strong>" + date + "</strong>";
                            }
                        }
                    },
                    series: [{
                        name: 'Number of Political Prisoners',
                        showInLegend: false,
                        data: response
                    }]
                });
            });
        }
    });
};