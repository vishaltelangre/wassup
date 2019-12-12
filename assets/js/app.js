// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.css"

// webpack automatically bundles all modules in your
// entry points. Those entry points can be configured
// in "webpack.config.js".
//
// Import dependencies
//
import "phoenix_html"

// Import local files
//
// Local files can be imported directly using relative paths, for example:
// import socket from "./socket"

import { renderLineChart } from "./charts/sentiment_line_chart";

document.addEventListener('DOMContentLoaded', function (event) {
  const targetNodeId = "sentiment-line-chart";
  const targetNode = document.getElementById(targetNodeId);
  if (!targetNode) return;

  const data = JSON.parse(targetNode.getAttribute("data-notes"));
  const sentimentDetails = JSON.parse(targetNode.getAttribute("data-sentiment-details"));

  renderLineChart(targetNodeId, data, { sentimentDetails, interactive: true });
});
