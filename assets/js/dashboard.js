import { renderLineChart } from "./charts/sentiment_line_chart";
import socket from "./socket";

let sentimentLineChartRef;

const joinChannel = () => {
  if (!socket) return;

  const channel = socket.channel(`note:dashboard:${App.userId}`, {});

  channel.on("refresh", ({body}) => {
    if (sentimentLineChartRef) {
      const data = JSON.parse(body);
      maybeDisposeChart();
      renderSentimentLineChart(data);
      refreshList(data);
    }
  });

  channel.join()
    .receive("ok", (response) => {
      if (sentimentLineChartRef) {
        const data = JSON.parse(response.body);
        maybeDisposeChart();
        renderSentimentLineChart(data)
        refreshList(data);
      }
    })
    .receive("error", resp => { console.error("Unable to join dashboard channel", resp) });

};

const maybeDisposeChart = () => {
  if (sentimentLineChartRef) {
    sentimentLineChartRef.dispose();
    sentimentLineChartRef = null;
  }
};

const renderSentimentLineChart = (data = []) => {
  const targetNodeId = "sentiment-line-chart";
  const targetNode = document.getElementById(targetNodeId);
  if (!targetNode) return;

  const { sentimentDetails } = App;

  sentimentLineChartRef = renderLineChart(targetNodeId, data, { sentimentDetails, interactive: false });
};

const refreshList = (data = []) => {
  const targetNodeId = ".dashboard #notes";
  const targetNode = document.querySelector(targetNodeId);
  if (!targetNode) return;

  const noteItem = ({body}) => `<li>${body}</<li>`;
  const html = data.map(noteItem).join("");
  targetNode.innerHTML = html;
};

export const initializeDashboard = () => {
  joinChannel();
  renderSentimentLineChart();
  refreshList();
};
