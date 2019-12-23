import { renderLineChart } from "./sentiment_line_chart";

export const renderDetailedTimelineChart = () => {
  const targetNodeId = "detailed-timeline-chart";
  const targetNode = document.getElementById(targetNodeId);
  if (!targetNode) return;

  const { sentimentDetails } = App;
  const data = JSON.parse(targetNode.getAttribute("data-notes"));

  renderLineChart(targetNodeId, data, { sentimentDetails, interactive: true });
};
