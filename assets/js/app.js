// We need to import the CSS so that webpack will load it.
// The MiniCssExtractPlugin is used to separate it out into
// its own CSS file.
import css from "../css/app.scss"

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
import socket from "./socket"
import "./dropdown";
import "./modal";
import { localizeDateTimes } from "./localize_datetime";
import "./daterange_picker";
import { initializeDashboard } from "./dashboard";
import "./note";
import { renderDetailedTimelineChart } from "./charts/detailed_timeline_chart";

document.addEventListener('DOMContentLoaded', () => {
  initializeDashboard();
  localizeDateTimes();
  renderDetailedTimelineChart();
});
