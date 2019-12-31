import socket from "./socket";
import { localizeDateTime, dateTimeFromNow } from "./localize_datetime";
import { renderLineChart } from "./charts/sentiment_line_chart";
import { renderPieChart } from "./charts/sentiment_pie_chart";
import { stringifyNote, favoriteToggleMarkup, actionsDropdownMarkup } from "./note";

let sentimentLineChartRef;
let sentimentPieChartRef;
const recentNotesSelector = ".dashboard [data-behavior='note-list']";
const recentNotesHeadingSelector = ".dashboard [data-behavior='note-list-heading']";
const sentimentLineChartId = "sentiment-line-chart";
const sentimentChartHeadingSelector = ".dashboard [data-behavior='sentiment-chart-heading']";
const sentimentPieChartId = "sentiment-pie-chart";

const onRefresh = ({ body }) => {
  if (sentimentLineChartRef) renderSentimentLineChart(JSON.parse(body));
  if (sentimentPieChartRef) renderSentimentPieChart(JSON.parse(body));
    refreshRecentNotes(JSON.parse(body));
};

const joinChannel = () => {
  if (!socket) return;

  const channel = socket.channel(`note:dashboard:${App.userId}`, {});

  channel.on("refresh", onRefresh);
  channel.join()
    .receive("ok", onRefresh)
    .receive("error", response => {
      console.error("Unable to join dashboard channel", response)
    });
};

const renderSentimentLineChart = (data = []) => {
  const sentimentLineChartElement = document.getElementById(sentimentLineChartId);
  if (!sentimentLineChartElement) return;

  const { sentimentDetails } = App;
  const options = { sentimentDetails, interactive: false };

  if (sentimentLineChartRef) {
    sentimentLineChartRef.dispose();
    sentimentLineChartRef = null;
  }

  sentimentLineChartRef = renderLineChart(sentimentLineChartId, data, options);

  toggleElementVisibility(document.querySelector(sentimentChartHeadingSelector), data.length);
  toggleElementVisibility(sentimentLineChartElement, data.length);
};

const renderSentimentPieChart = (data = []) => {
  const sentimentPieChartElement = document.getElementById(sentimentPieChartId);
  if (!sentimentPieChartElement) return;

  if (sentimentPieChartRef) {
    sentimentPieChartRef.dispose();
    sentimentPieChartRef = null;
  }

  sentimentPieChartRef = renderPieChart(sentimentPieChartId, data);

  toggleElementVisibility(sentimentPieChartElement, data.length);
};

const noteItemMarkup = note => {
  const { id, body, sentiment_color, submitted_at } = note;
  const localDateTime =
    localizeDateTime(submitted_at).format('MMM DD, YYYY - hh:mm:ss A');
  const maxBodyLength = 120;

  return `
    <li class="row"
        style="border-right: 5px solid ${sentiment_color};"
        data-behavior="note-item"
        data-note-id="${id}"
        data-note-item-context="dashboard">
      <div class="meta column column-33">
        <span class="label" title="${localDateTime}">
          ${dateTimeFromNow(submitted_at)}
        </span>
        ${favoriteToggleMarkup(note)}
      </div>
      <div class="column column-67">
        <div class="row">
          <p class="column column-80"
              data-behavior="note-body"
              data-truncate="${maxBodyLength}">
            ${truncateNoteBody(note, maxBodyLength)}
          </p>
          <div class="column column-20">
            ${actionsDropdownMarkup(note)}
          </div>
        </div>
      </div>
    </<li>
  `;
};

const refreshRecentNotes = (data = []) => {
  const recentNotesElement = document.querySelector(recentNotesSelector);
  if (!recentNotesElement) return;

  recentNotesElement.innerHTML = data.map(noteItemMarkup).join("");

  toggleElementVisibility(document.querySelector(recentNotesHeadingSelector), data.length);
  toggleElementVisibility(recentNotesElement, data.length)
};

const toggleElementVisibility = (headingElement, show) => {
  if (show) {
    headingElement.classList.add("show");
  } else {
    headingElement.classList.remove("show");
  }
};

const truncateNoteBody = (note, maxLength) => {
  const { body } = note;
  const elipsis = body.length > maxLength
    ? ` <a href="javascript:void(0)"
           data-note='${stringifyNote(note)}'
           data-behavior="note-preview-trigger"
           title="Read More">…</a>
        `
    : "";
  return body.substring(0, maxLength) + elipsis;
};

const initializeDashboard = () => {
  joinChannel();
  renderSentimentLineChart();
  renderSentimentPieChart();
  refreshRecentNotes();
};

export {
  truncateNoteBody,
  initializeDashboard,
  renderSentimentPieChart
};
