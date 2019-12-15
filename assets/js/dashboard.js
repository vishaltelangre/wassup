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

const relativeTime = time => {
  const msPerMinute = 60 * 1000;
  const msPerHour = msPerMinute * 60;
  const msPerDay = msPerHour * 24;
  const msPerMonth = msPerDay * 30;
  const msPerYear = msPerDay * 365;

  const elapsed = new Date() - time;

  if (elapsed < msPerMinute) {
    return Math.round(elapsed / 1000) + ' seconds ago';
  }

  else if (elapsed < msPerHour) {
    return Math.round(elapsed / msPerMinute) + ' minutes ago';
  }

  else if (elapsed < msPerDay) {
    return Math.round(elapsed / msPerHour) + ' hours ago';
  }

  else if (elapsed < msPerMonth) {
    return 'about ' + Math.round(elapsed / msPerDay) + ' days ago';
  }

  else if (elapsed < msPerYear) {
    return 'about ' + Math.round(elapsed / msPerMonth) + ' months ago';
  }

  else {
    return 'about ' + Math.round(elapsed / msPerYear) + ' years ago';
  }
}

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

    return `
      <li class="row" style="border-left: 5px solid ${sentimentDetails[sentimentName].color};">
        <div class="meta column column-33">
          <span class="label">${relativeTime(date)}</span>

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
