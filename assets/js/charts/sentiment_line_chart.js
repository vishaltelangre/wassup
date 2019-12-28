import * as am4core from "@amcharts/amcharts4/core";
import * as am4charts from "@amcharts/amcharts4/charts";
import am4themes_animated from "@amcharts/amcharts4/themes/animated";
import am4themes_dark from "@amcharts/amcharts4/themes/dark";

import { truncateNoteBodyForChartTooltip } from "./utils";

// Chart colors
const fixedPeriodContainerLabelColor = am4core.color("#555");
const fixedPeriodContainerBackgroundColor = am4core.color("#000");
const zoomOutButtonBackgroundColor = am4core.color("#555");
const zoomOutButtonHoverBackgroundColor = am4core.color("#606271");
const zoomOutButtonStrokeColor = am4core.color("#EFD9CE");
const dateAxisTickLabelColor = am4core.color("#888");
const primarySeriesFillColor = am4core.color("#000");
const primarySeriesTooltipBackgroundColor = am4core.color("#111");

// Date format to present dates in
const displayDateFormat = "MMM dd, YYYY - hh:mm:ss a";

const globalSetup = () => {
  // Enable themes
  am4core.useTheme(am4themes_dark);
  am4core.useTheme(am4themes_animated);
};

// Function to add "From" and "To" labels to the fixed period container
const createPeriodLabel = (parent, field, title) => {
  const fontSize = 11;
  const titleLabel = parent.createChild(am4core.Label);
  const valueLabel = parent.createChild(am4core.Label);

  // Title configuration
  titleLabel.text = `${title}: `;
  titleLabel.fontSize = fontSize;
  titleLabel.minWidth = 30;
  titleLabel.marginRight = 5;
  titleLabel.fill = fixedPeriodContainerLabelColor;

  // Value configuration
  valueLabel.id = field;
  valueLabel.text = "-";
  valueLabel.fontSize = fontSize;
  valueLabel.minWidth = 125;
  valueLabel.fontWeight = "bold";
  valueLabel.fill = fixedPeriodContainerLabelColor;
};

// Callback function to update the "From" and "To" label values in the fixed
// period container
const updatePeriodLabelValues = chart => {
  // Grab "minimum" and "maximum" dates on date axis
  const { xAxis: { minZoomed, maxZoomed }, xAxis } = chart.series.getIndex(0);
  const fromLabel = chart.map.getKey("from");
  const toLabel = chart.map.getKey("to");

  if (fromLabel && toLabel) {
    fromLabel.text = xAxis.formatLabel(minZoomed);
    toLabel.text = xAxis.formatLabel(maxZoomed);
  }
}

const createChart = (targetNodeId, data) => {
  const chart = am4core.create(targetNodeId, am4charts.XYChart);
  // Create initial fade-in
  chart.hiddenState.properties.opacity = 0;
  // Make responsive
  chart.responsive.enabled = true;
  // Set input format for the dates
  chart.dateFormatter.inputDateFormat = "i";
  // Sort data in ascending order
  chart.events.on("beforedatavalidated", () => {
    chart.data.sort((a, b) => {
      return (new Date(a.submitted_at)) - (new Date(b.submitted_at));
    });
  });
  // Update label values on fixed period container when chart initializes
  chart.events.on("ready", () => {
    updatePeriodLabelValues(chart);
  });
  // Set data.
  // Inject additional "short_body" attribute to every "note" item in the data
  // with the truncated "body" attribute when it is exceeding defined length.
  // On clicking on the truncated body in a tooltip, attach data attributes
  // to trigger a modal with the detailed note preview.
  chart.data = data.map(note => {
    note.short_body = truncateNoteBodyForChartTooltip(note);

    return note;
  });

  return chart;
};

// Fixed period container to display current "From" and "To" dates on date axis
const createFixedPeriodContainer = chart => {
  const container = chart.plotContainer.createChild(am4core.Container);
  container.width = 200;
  container.height = 35;
  container.x = 20;
  container.y = -10;
  container.padding(5, 5, 5, 10);
  container.background.fill = fixedPeriodContainerBackgroundColor;
  container.background.fillOpacity = 0.2;
  container.layout = "grid";
  container.filters.push(new am4core.DropShadowFilter());

  createPeriodLabel(container, "from", "FROM")
  createPeriodLabel(container, "to", "TO")
}

const configureZoomOutButton = (chart, interactive) => {
  if (interactive) {
    chart.zoomOutButton.scale = 0.5;
    chart.zoomOutButton.background.cornerRadius(5, 5, 5, 5);
    chart.zoomOutButton.background.fill = zoomOutButtonBackgroundColor;
    chart.zoomOutButton.icon.stroke = zoomOutButtonStrokeColor;
    chart.zoomOutButton.icon.strokeWidth = 2;
    chart.zoomOutButton.background.states.getKey("hover").properties.fill = zoomOutButtonHoverBackgroundColor;
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
  dateAxis.extraMin = interactive ? 0.04 : 0.06;
  dateAxis.extraMax = interactive ? 0.006 : 0.03;
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
  dateAxis.renderer.labels.template.fill = dateAxisTickLabelColor;
  dateAxis.renderer.labels.template.fontSize = 14;
  // Axis tooltip customizations
  dateAxis.cursorTooltipEnabled = false;
  // Date format used to format values obtained from this axis using the
  // "dateAxis.formatLabel" function
  dateAxis.dateFormatter.dateFormat = displayDateFormat;
  // Update the "From" and "To" date values in fixed period container whenever
  // date axis extremes are changed (e.g. by dragging the sliders on scrollbar).
  dateAxis.events.on("selectionextremeschanged", event => {
    updatePeriodLabelValues(chart);
  });

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
  series.fill = primarySeriesFillColor;
  series.fillOpacity = 0.2;
  series.defaultState.transitionDuration = 1000;
  series.tensionX = 1;
  series.tensionY = 1;
  series.strokeWidth = 4;
  series.connect = true;
  // If distance gets smaller than this, bullets are hidden to avoid overlapping
  series.minBulletDistance = 15;
  series.simplifiedProcessing = true;

  series.tooltipHTML = `
    <div class="tooltip note-preview">
      <div class="meta">
        <span class="label">{submitted_at.formatDate("${displayDateFormat}")}</span>
        <img class="icon" src="/images/{sentiment}.svg" />
        <img class="icon star-icon" src="{graph_favorite_icon_path}" />
      </div>
      {short_body}
    </div>
  `;
  series.tooltip.getFillFromObject = false;
  series.tooltip.pointerOrientation = "vertical";
  series.tooltip.background.fill = primarySeriesTooltipBackgroundColor;
  series.tooltip.background.fillOpacity = 0.9;
  series.tooltip.background.cornerRadius = 5;
  series.tooltip.background.strokeOpacity = 0;
  series.tooltip.label.interactionsEnabled = true;
  series.tooltip.keepTargetHover = true;

  return series;
};

const createSentimentRangeOnValueAxis = (sentiment, sentimentDetails, series, valueAxis, interactive) => {
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
  const emojiSize = interactive ? 48 : 28;
  emoji.href = `/images/${sentiment}.svg`;
  emoji.width = emojiSize;
  emoji.height = emojiSize;
  emoji.horizontalCenter = "middle";
  emoji.verticalCenter = "middle";
  emoji.filters.push(new am4core.DropShadowFilter());
};

const createDataItemBullets = series => {
  const bullet = series.bullets.push(new am4charts.CircleBullet());
  bullet.hoverOnFocus = true;
  bullet.strokeOpacity = 0;
  bullet.filters.push(new am4core.DropShadowFilter());
  // Colorize bullet with the sentiment's color
  bullet.adapter.add("fill", (fill, { dataItem: { dataContext: { sentiment_color } } }) => am4core.color(sentiment_color));
  const favoriteIcon = bullet.createChild(am4core.Image);
  favoriteIcon.propertyFields.href = "graph_favorite_icon_path";
  favoriteIcon.width = 24;
  favoriteIcon.height = 24;
  favoriteIcon.horizontalCenter = "middle";
  favoriteIcon.verticalCenter = "middle";
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
  // Create a horizontal scrollbar and place it beneath the date axis
  const scrollbar = new am4charts.XYChartScrollbar();
  scrollbar.series.push(scrollbarSeries);
  scrollbar.marginTop = 40;
  scrollbar.height = 30;
  scrollbar.fillOpacity = 0;
  scrollbar.strokeOpacity = 0;
  scrollbar.draggable = false;
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
    valueFieldName = "sentiment_value",
    interactive = true
  }) => {
    let chart;

  am4core.ready(() => {
    globalSetup();
    chart = createChart(targetNodeId, data);

    if (interactive) {
      createFixedPeriodContainer(chart);
    }

    configureZoomOutButton(chart, interactive);

    const dateAxis = createDateAxis(chart, data, interactive);
    const valueAxis = createValueAxis(chart);
    const series = createPrimarySeries(chart, dateFieldName, valueFieldName);

    Object.keys(sentimentDetails).forEach(sentiment => {
      createSentimentRangeOnValueAxis(sentiment, sentimentDetails, series, valueAxis, interactive);
    });

    createDataItemBullets(series);

    createPanningCursor(chart, series, dateAxis);

    if (interactive) {
      createScrollbar(chart, dateFieldName, valueFieldName);
    }

  });

  return chart;
});
