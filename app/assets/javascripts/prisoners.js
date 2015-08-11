function addDateOfBirthPicker() {
  $(".date_of_birth_select").datepicker({
    dateFormat: "yy-mm-dd",
    changeMonth: true,
    changeYear: true,
    yearRange: "-100:+0"
  });
}

$(document).ready(function() {
  if ($("form.prisoner").length) {
    addDateOfBirthPicker();
  }
});

function imprisonedCountTimeline() {
  $.ajax({
    url: gon.imprisoned_count_timeline_prisoners_path,
    async: true,
    dataType: "json",
    success: function (response) {
      var data = response.data;
      var text = response.text;

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
              var summary = '';
              var prisonerCount = this.point.y;
              var date = Highcharts.dateFormat(text.date_format, new Date(this.point.x));

              if (prisonerCount === '1') {
                summary = text.date_summary.one;
              } else {
                summary = text.date_summary.other;
              }

              summary = summary.replace('%{number_prisoners}','<strong>' + prisonerCount + '</strong>');
              summary = summary.replace('%{date}','<strong>' + date + '</strong>');

              return summary;
            },
            useHTML: true,
            style: { padding: "1px" }
          },
          series: [{
            name: text.number_prisoners,
            showInLegend: false,
            data: data,
            turboThreshold: 0
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
