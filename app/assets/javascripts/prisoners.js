// Add jQuery Select2 extra functionality to Charges multiple select
function addSelect2() {
    $("select.charges_select").select2({
        placeholder: "Select Charges",
        width: "400px"
    });

    $("select.tags_select").select2({
        placeholder: "Select Tags",
        width: "400px"
    });
}

function addDatePickers() {
    $(".date_of_arrest_select, .date_of_release_select").datepicker({
        dateFormat: "yy-mm-dd",
        changeMonth: true,
        changeYear: true
    });
}

$(document).ready(function() {
  if ($("form.prisoner").length) {
    addSelect2();
    loadTinymce();
    addDatePickers();
    $(".container, #links").on("cocoon:after-insert", function(e, insertedItem) {
      addSelect2();
      loadTinymce();
      addDatePickers();
    });

    $(document).on("click", ".nested-fields h3 .tree-toggle", function(){
      var t = $(this);
      t.find("span").toggleClass("fa-caret-right fa-caret-down");
      t.closest(".nested-fields").find(".container").toggle();
    });
  }

  $("[data-toggle=\"tooltip\"]").tooltip();
});

$(document).on("page:receive", function() {
    tinymce.remove();
});

function imprisonedCountTimeline() {
    $.ajax({
        url: gon.imprisoned_count_timeline_prisoners_path,
        async: true,
        dataType: "json",
        success: function (response) {
            $(function () {
                $("#imprisoned-count-timeline").highcharts({
                    chart: {
                        zoomType: "x",
                        pinchType: "none",
                        resetZoomButton: {
                            position: {
                                align: "left",
                                verticalAlign: "top",
                                x: 10,
                                y: 10
                            }
                        }
                    },
                    title: {
                        text: "How has the number of political prisoners changed over time?",
                        useHTML: true
                    },
                    subtitle: {
                        text: "<a href=\"" + gon.prisoners_path + "\">Click here to explore prisoners</a>",
                        useHTML: true
                    },
                    xAxis: {
                        type: "datetime",
                        minRange: 14 * 24 * 3600000 // fourteen days
                    },
                    yAxis: {
                        title: {
                            text: "Number of Political Prisoners"
                        },
                        min: 0,
                        allowDecimals: false
                    },
                    tooltip: {
                        formatter: function() {
                            var prisonerCount = this.point.y;
                            var date = Highcharts.dateFormat("%A, %b %e, %Y", new Date(this.point.x));
                            if ( prisonerCount === "1" ) {
                                return "There was <strong>" + prisonerCount + "</strong> political prisoner in Azerbaijan on <strong>" + date + "</strong>";
                            }
                            else {
                                return "There were <strong>" + prisonerCount + "</strong> political prisoners in Azerbaijan on <strong>" + date + "</strong>";
                            }
                        },
                        useHTML: true,
                        style: { padding: "1px" }
                    },
                    series: [{
                        name: "Number of Political Prisoners",
                        showInLegend: false,
                        data: response
                    }]
                });
            });
        }
    });
}
