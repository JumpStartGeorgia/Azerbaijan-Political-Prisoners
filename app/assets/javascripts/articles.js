$(document).ready(function() {
  if ($('form.article').length) {
    loadTinymce();
  }
});

function article_incident_counts_chart() {
  $.ajax({
    url: gon.article_incident_counts_articles_path,
    async: true,
    dataType: 'json',
    success: function (response) {
      var text = response.text;
      var data = response.data;

      Highcharts.setOptions({
        lang: {
          contextButtonTitle: text.highcharts.context_title
        }
      });

      $('#top-10-charge-counts').highcharts({
        chart: {
          type: 'bar'
        },
        title: {
          text: text.title,
          useHTML: true
        },
        subtitle: {
          text: '<a href="' + text.articles_path + '">' + text.explore_charges + '</a>',
          useHTML: true
        },
        yAxis: {
          title: {
            text: text.y_axis_label
          },
          allowDecimals: false
        },
        xAxis: {
          categories: data,
          title: {
            text: text.x_axis_label
          },
          labels: {
            formatter: function() {
              return '<a href="' + this.value.link + '">' + this.value.number + '</a>';
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
          name: text.y_axis_label,
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
    }
  });
}
