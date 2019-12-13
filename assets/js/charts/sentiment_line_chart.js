import * as am4core from "@amcharts/amcharts4/core";
import * as am4charts from "@amcharts/amcharts4/charts";
import am4themes_animated from "@amcharts/amcharts4/themes/animated";

const globalSetup = () => {
  // Enable themes
  am4core.useTheme(am4themes_animated);
};

const createChart = (targetNodeId, data) => {
  const chart = am4core.create(targetNodeId, am4charts.XYChart);
  // Create initial fade-in
  chart.hiddenState.properties.opacity = 0;
  // Make responsive
  chart.responsive.enabled = true;
  // Set input format for the dates
  chart.dateFormatter.inputDateFormat = "i";
  // Set data
  chart.data = data;

  return chart;
};

const configureZoomOutButton = (chart, interactive) => {
  if (interactive) {
    chart.zoomOutButton.scale = 0.5;
    chart.zoomOutButton.background.cornerRadius(5, 5, 5, 5);
    chart.zoomOutButton.background.fill = am4core.color("#555");
    chart.zoomOutButton.icon.stroke = am4core.color("#EFD9CE");
    chart.zoomOutButton.icon.strokeWidth = 2;
    chart.zoomOutButton.background.states.getKey("hover").properties.fill = am4core.color("#606271");
  } else {
    chart.zoomOutButton.disabled = true;
  }
};

const createDateAxis = (chart, data, interactive) => {
  const dateAxis = chart.xAxes.push(new am4charts.DateAxis());
  dateAxis.renderer.grid.template.strokeOpacity = 0.1;
  dateAxis.renderer.grid.template.location = 0;
  // Aggregate when dataset is large
  dateAxis.groupData = false;
  // Zoom-in to the small subset when dataset contains more than 31 items
  dateAxis.start = interactive && (data.length > 31) ? 0.8 : 0;
  dateAxis.keepSelection = true;
  // Add small spacing from left and right on date axis to avoid clipping graph
  dateAxis.extraMin = 0.04;
  dateAxis.extraMax = 0.04;
  // Data granularity
  dateAxis.baseInterval = {
    timeUnit: "minute",
    count: 1
  };
  // Format tick labels based on zoom-level
  dateAxis.dateFormats.setKey("minute", "hh:mm a");
  dateAxis.periodChangeDateFormats.setKey("minute", "hh:mm a");
  dateAxis.dateFormats.setKey("hour", "hh:mm a");
  dateAxis.periodChangeDateFormats.setKey("hour", "hh:mm a");
  dateAxis.dateFormats.setKey("day", "MMM d");
  dateAxis.periodChangeDateFormats.setKey("day", "MMM d, yyyy");
  dateAxis.dateFormats.setKey("month", "MMMM yyyy");
  dateAxis.periodChangeDateFormats.setKey("month", "MMMM yyyy");
  // Tick label customizations
  dateAxis.renderer.labels.template.fill = am4core.color("#888");
  dateAxis.renderer.labels.template.fontSize = 14;
  // Axis tooltip customizations
  dateAxis.cursorTooltipEnabled = true;
  dateAxis.tooltipDateFormat = "MMM d, yyyy";
  const { tooltip: { background: tooltipBackground }, tooltip} = dateAxis;
  tooltip.fontSize = 14;
  tooltipBackground.fillOpacity = 0.6;
  tooltipBackground.strokeOpacity = 0.6;
  tooltipBackground.cornerRadius = 5;

  return dateAxis;
};

const createValueAxis = chart => {
  const valueAxis = chart.yAxes.push(new am4charts.ValueAxis());
  valueAxis.cursorTooltipEnabled = false;
  valueAxis.renderer.grid.template.location = 0;
  valueAxis.renderer.grid.template.strokeOpacity = 0;
  valueAxis.renderer.minGridDistance = 40;
  // Fixed minimum and maximum ticks on value axis
  valueAxis.min = 0;
  valueAxis.max = 4;
  // Hide tick labels
  valueAxis.renderer.labels.template.disabled = true;

  return valueAxis;
};

const createPrimarySeries = (chart, dateFieldName, valueFieldName) => {
  const series = chart.series.push(new am4charts.LineSeries());
  series.dataFields.dateX = dateFieldName;
  series.dataFields.valueY = valueFieldName;
  series.sequencedInterpolation = true;
  series.fill = am4core.color("#9cc");
  series.fillOpacity = 0.1;
  series.defaultState.transitionDuration = 1000;
  series.tensionX = 1;
  series.tensionY = 1;
  series.strokeWidth = 4;
  series.connect = true;
  // If distance gets smaller than this, bullets are hidden to avoid overlapping
  series.minBulletDistance = 15;
  series.simplifiedProcessing = true;

  return series;
};

const createSentimentRangeOnValueAxis = (sentiment, sentimentDetails, series, valueAxis) => {
  const { value, color } = sentimentDetails[sentiment];
  // Create vertical range on series around the sentiment value
  const range = valueAxis.createSeriesRange(series);
  range.value = value + 0.5;
  range.endValue = value - 0.5;
  // Colorize the line depending on the sentiment
  range.contents.stroke = am4core.color(color);
  range.contents.strokeOpacity = 1;
  range.contents.fillOpacity = series.fillOpacity;
  // Create a bullet on range
  const bullet = new am4charts.AxisBullet();
  bullet.location = 0.5; // display in the center of the range
  range.bullet = bullet;
  // Display the sentiment emoji on that bullet
  const emoji = range.bullet.createChild(am4core.Image);
  emoji.href = `/images/${sentiment}.svg`;
  emoji.width = 48;
  emoji.height = 48;
  emoji.horizontalCenter = "middle";
  emoji.verticalCenter = "middle";
  emoji.filters.push(new am4core.DropShadowFilter());
};

const createDataItemBullets = (series, sentimentDetails) => {
  const bullet = series.bullets.push(new am4charts.CircleBullet());
  bullet.hoverOnFocus = true;
  bullet.stroke = am4core.color("#fff");
  // Colorize bullet with the sentiment's color
  bullet.adapter.add("fill", (fill, target) => {
    const { valueY } = target.dataItem;
    const color = Object.keys(sentimentDetails).reduce((defaultColor, sentiment) => {
      const { value, color } = sentimentDetails[sentiment];
      return value === valueY ? color : defaultColor;
    }, "#eee");
    return am4core.color(color);
  });
  // Make bullets grow on hover
  const hoverState = bullet.states.create("hover");
  hoverState.properties.scale = 1.3;
};

const createPanningCursor = (chart, series, dateAxis) => {
  const cursor = new am4charts.XYCursor();
  cursor.behavior = "panX";
  cursor.xAxis = dateAxis;
  cursor.snapToSeries = series;
  cursor.lineX.opacity = 0.7;
  cursor.lineY.opacity = 0.7;
  cursor.cursorDownStyle = am4core.MouseCursorStyle.grabbing;
  chart.cursor = cursor;
};

const createScrollbar = (chart, dateFieldName, valueFieldName) => {
  // A separate series for scrollbar
  const scrollbarSeries = chart.series.push(new am4charts.LineSeries());
  scrollbarSeries.dataFields.dateX = dateFieldName;
  scrollbarSeries.dataFields.valueY = valueFieldName;
  // Need to set on default state, as initially series is "show"
  scrollbarSeries.defaultState.properties.visible = false;
  // Hide this series from legend, too (in case there is one)
  scrollbarSeries.hiddenInLegend = true;
  scrollbarSeries.fillOpacity = 0.1;
  scrollbarSeries.strokeOpacity = 0.2;
  // Create a horizontal scrollbar and place it beneath the date axis
  var scrollbar = new am4charts.XYChartScrollbar();
  scrollbar.series.push(scrollbarSeries);
  scrollbar.marginTop = 40;
  scrollbar.height = 30;
  chart.scrollbarX = scrollbar;
  scrollbar.parent = chart.bottomAxesContainer;
  // Hide scrollbar series otherwise it is displayed on top of the primary
  // series in the chart
  scrollbarSeries.hide();
};

export const renderLineChart = ((
  targetNodeId,
  data,
  {
    sentimentDetails = {},
    dateFieldName = "submitted_at",
    valueFieldName = "sentiment",
    interactive = true
  }) => {
  am4core.ready(() => {
    globalSetup();
    const chart = createChart(targetNodeId, data);
    configureZoomOutButton(chart, interactive);
    const dateAxis = createDateAxis(chart, data, interactive);
    const valueAxis = createValueAxis(chart);
    const series = createPrimarySeries(chart, dateFieldName, valueFieldName);
    Object.keys(sentimentDetails).forEach(sentiment => {
      createSentimentRangeOnValueAxis(sentiment, sentimentDetails, series, valueAxis);
    });
    createDataItemBullets(series, sentimentDetails);

    if (interactive) {
      createPanningCursor(chart, series, dateAxis);
      createScrollbar(chart, dateFieldName, valueFieldName);
    }
  });
});
