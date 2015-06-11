// Place all the behaviors and hooks related to the matching controller here.
// All this logic will automatically be available in application.js.

// Add jQuery Select2 extra functionality to Charges multiple select
var addSelect2 = function() {
    $('select.charges_select').select2({
        placeholder: 'Select Charges',
        width: '400px'
    });

    $('select.tags_select').select2({
        placeholder: 'Select Tags',
        width: '400px'
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
        $('.container, #links').on('cocoon:after-insert', function(e, insertedItem) {
            addSelect2();
            loadTinymce();
            addDatePickers();
        });
    }
  $(document).on('click', '.nested-fields h3 .tree-toggle', function(){
    var t = $(this);
    t.find('span').toggleClass('fa-caret-right fa-caret-down');
    t.closest('.nested-fields').find('.container').toggle();
  });
});

var imprisoned_count_timeline = function() {
    $.ajax({
        url: gon.imprisoned_count_timeline_prisoners_path,
        async: true,
        dataType: 'json',
        success: function (response) {
            $(function () {
                $('#imprisoned-count-timeline').highcharts({
                    chart: {
                        zoomType: 'x',
                        pinchType: 'none',
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
                        text: 'How has the number of political prisoners changed over time?',
                        useHTML: true
                    },
                    subtitle: {
                        text: '<a href="' + gon.prisoners_path + '">Click here to explore prisoners</a>',
                        useHTML: true
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
                        },
                        useHTML: true,
                        style: { padding: '1px' }
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
