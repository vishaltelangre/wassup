import * as am4core from "@amcharts/amcharts4/core";
import * as am4charts from "@amcharts/amcharts4/charts";

const { sentimentDetails } = App;

const transformPieChartData = data => Object.keys(sentimentDetails).map(sentiment => ({
  sentiment,
  color: am4core.color(sentimentDetails[sentiment].color),
  percent: data.filter(note => sentiment === note.sentiment).length
}));

const renderPieChart = (sentimentPieChartId, data) => {
  const sentimentPieChartElement = document.getElementById(sentimentPieChartId);
  const chart = am4core.create(sentimentPieChartElement, am4charts.PieChart);
  chart.paddingTop = 20;
  chart.data = transformPieChartData(data);
  chart.innerRadius = am4core.percent(50);

  const series = chart.series.push(new am4charts.PieSeries());
  series.dataFields.value = "percent";
  series.dataFields.category = "sentiment";
  series.slices.template.propertyFields.fill = "color";
  series.slices.template.cornerRadius = 5;
  series.slices.template.innerCornerRadius = 5;
  series.labels.template.html = `
    <span class='pie-chart-label'>
      <img src='/images/{category}.svg' />
      <span class='percent'>{value.percent.formatNumber('##.#')}%</span>
    </span>`;
  series.ticks.template.disabled = true;
  series.tooltip.disabled = true;

  return chart;
};

export { transformPieChartData, renderPieChart };
