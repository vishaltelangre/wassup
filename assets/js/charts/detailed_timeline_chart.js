import { renderLineChart } from "./sentiment_line_chart";

const renderDetailedTimelineChart = () => {
  const targetNodeId = "detailed-timeline-chart";
  const targetNode = document.getElementById(targetNodeId);
  if (!targetNode) return;

  const { sentimentDetails } = App;
  const data = JSON.parse(targetNode.getAttribute("data-notes"));

  renderLineChart(targetNodeId, data, { sentimentDetails, interactive: true });
};

export { renderDetailedTimelineChart };
