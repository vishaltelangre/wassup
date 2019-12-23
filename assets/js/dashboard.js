import { renderLineChart } from "./charts/sentiment_line_chart";
import socket from "./socket";
import { localizeDateTime, dateTimeFromNow } from "./localize_datetime";

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

const truncate = (text, length) => {
  const elipsis = text.length > length ? '...' : '';
  return text.substring(0, length) + elipsis;
};

const refreshList = (data = []) => {
  const targetNodeId = ".dashboard #notes";
  const targetNode = document.querySelector(targetNodeId);
  const { sentimentDetails } = App;
  if (!targetNode) return;

  const noteItem = ({body, sentiment, favorite, submitted_at, color}) => {
    const date = new Date(submitted_at);
    const sentimentName = Object.keys(App.sentimentDetails).filter((key) => {
      const { value } = App.sentimentDetails[key];
      return value === sentiment;
    })[0];
    const localDateTime = localizeDateTime(date).format('MMM DD, YYYY - hh:mm:ss A');

    return `
      <li class="row" style="border-left: 5px solid ${sentimentDetails[sentimentName].color};">
        <div class="meta column column-33">
          <span class="label" title="${localDateTime}">${dateTimeFromNow(date)}</span>

        </div>
        <p class="column column-67" title="${body}">${truncate(body, 75)}</p>
      </<li>
    `;
  };
  const html = data.map(noteItem).join("");
  targetNode.innerHTML = html;
};

export const initializeDashboard = () => {
  joinChannel();
  renderSentimentLineChart();
  refreshList();
};
