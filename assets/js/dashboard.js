import { renderLineChart } from "./charts/sentiment_line_chart";
import socket from "./socket";

let sentimentLineChartRef;

const joinChannel = () => {
  if (!socket) return;

  const channel = socket.channel(`note:dashboard:${App.userId}`, {});

  channel.on("refresh", ({body}) => {
    if (sentimentLineChartRef) {
      maybeDisposeChart();
      renderSentimentLineChart(JSON.parse(body))
    }
  });

  channel.join()
    .receive("ok", (response) => {
      if (sentimentLineChartRef) {
        maybeDisposeChart();
        renderSentimentLineChart(JSON.parse(response.body))
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

  sentimentLineChartRef = renderLineChart(targetNodeId, data, { sentimentDetails, interactive: true });
};

export const initializeDashboard = () => {
  joinChannel();
  renderSentimentLineChart();
};
