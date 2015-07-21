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
  $(".date_of_arrest_select, .date_of_release_select, .date_of_birth_select").datepicker({
    dateFormat: "yy-mm-dd",
    changeMonth: true,
    changeYear: true,
    yearRange: "-100:+0"
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
      data = response.data
      text = response.text

      Highcharts.setOptions({
        lang: {
          contextButtonTitle: text.highcharts.context_title
        }
      });

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
            text: text.title,
            useHTML: true
          },
          subtitle: {
            text: "<a href=\"" + text.prisoners_path + "\">" + text.explore_prisoners + "</a>",
            useHTML: true
          },
          xAxis: {
            type: "datetime",
            minRange: 14 * 24 * 3600000 // fourteen days
          },
          yAxis: {
            title: {
              text: text.number_prisoners
            },
            min: 0,
            allowDecimals: false
          },
          tooltip: {
            formatter: function() {
              return this.point.date_summary;
            },
            useHTML: true,
            style: { padding: "1px" }
          },
          series: [{
            name: text.number_prisoners,
            showInLegend: false,
            data: data
          }],
          exporting: {
            buttons: {
              contextButton: {
                menuItems: [
                  {
                    text: text.highcharts.png,
                    onclick: function () {
                      this.exportChart({type: 'image/png'});
                    }
                  },
                  {
                    text: text.highcharts.jpg,
                    onclick: function () {
                      this.exportChart({type: 'image/jpeg'});
                    }
                  },
                  {
                    text: text.highcharts.pdf,
                    onclick: function () {
                      this.exportChart({type: 'application/pdf'});
                    }
                  },
                  {
                    text: text.highcharts.svg,
                    onclick: function () {
                      this.exportChart({type: 'image/svg+xml'});
                    }
                  }
                ]
              }
            }
          }
        });
      });
    }
  });
}
