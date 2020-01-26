import "mdn-polyfills/CustomEvent";
import "mdn-polyfills/String.prototype.startsWith";
import "mdn-polyfills/Array.from";
import "mdn-polyfills/NodeList.prototype.forEach";
import "mdn-polyfills/Element.prototype.closest";
import "mdn-polyfills/Element.prototype.matches";
import "child-replace-with-polyfill";
import "url-search-params-polyfill";
import "formdata-polyfill";
import "classlist-polyfill";
import { Socket } from "phoenix";
import LiveSocket from "phoenix_live_view";
import rome from "@bevacqua/rome";
import { renderLineChart, transformLineChartData } from "./charts/sentiment_line_chart";
import { renderPieChart, transformPieChartData } from "./charts/sentiment_pie_chart";

const { moment } = rome;
const Hooks = {};

Hooks.DashboardSentimentLineChart = {
  mounted() {
    const { sentimentDetails } = App;
    const options = { sentimentDetails, interactive: false };
    this.rawData = this.el.getAttribute("data-chart");
    const data = JSON.parse(this.rawData);
    this.chartRef = renderLineChart(this.el.getAttribute("id"), data, options);
  },

  updated() {
    const rawData = this.el.getAttribute("data-chart");

    if (rawData === this.rawData) return;

    this.rawData = rawData;
    const data = JSON.parse(this.rawData);
    this.chartRef.data = transformLineChartData(data);
  },

  destroyed() {
    this.chartRef.dispose();
  }
};

Hooks.DashboardSentimentPieChart = {
  mounted() {
    const data = JSON.parse(this.el.getAttribute("data-chart"));
    this.chartRef = renderPieChart(this.el.getAttribute("id"), data);
  },

  updated() {
    const data = JSON.parse(this.el.getAttribute("data-chart"));

    this.chartRef.data = transformPieChartData(data);
  },

  destroyed() {
    this.chartRef.dispose();
  }
};

Hooks.DetailedSentimentLineChart = {
  mounted() {
    const { sentimentDetails } = App;
    const options = { sentimentDetails, interactive: true };
    this.rawData = this.el.getAttribute("data-chart");
    const data = JSON.parse(this.rawData);
    this.chartRef = renderLineChart(this.el.getAttribute("id"), data, options);
  },

  updated() {
    const rawData = this.el.getAttribute("data-chart");

    if (rawData === this.rawData) return;

    this.rawData = rawData;
    const data = JSON.parse(this.rawData);
    this.chartRef.data = transformLineChartData(data);
  },

  destroyed() {
    this.chartRef.dispose();
  }
};

Hooks.NotesDateRangePicker = {
  mounted() {
    this.renderDateRangePicker = () => {
      const dateFormat = "MMM DD, YYYY";
      const from = this.el.querySelector(
        "[data-behavior=daterange-picker-from-calendar]"
      );
      const to = this.el.querySelector(
        "[data-behavior=daterange-picker-to-calendar]"
      );
      const cancelButton = this.el.querySelector(
        "[data-behavior=cancel-daterange]"
      );
      const applyButton = this.el.querySelector(
        "[data-behavior=apply-daterange]"
      );
      const dropdownContent = this.el.querySelector(
        "[data-behavior=dropdown-content]"
      );
      const value = this.el.querySelector("[data-behavior=value]").value || "";
      const [rawInitialFromValue, rawInitialToValue] = value.trim().split("-");
      const initialFromValue = moment(rawInitialFromValue.trim(), dateFormat);
      const initialToValue = moment((rawInitialToValue || "").trim(), dateFormat);

      // "From" calendar configuration
      this.fromCalendar = rome(from, {
        weekStart: 1,
        time: false,
        dateValidator: rome.val.beforeEq(to),
        max: moment(),
        initialValue: initialFromValue.isValid() && initialFromValue
      }).on("data", fromDate => {
        const fromDateMoment = moment(fromDate);
        const fromCalendar = rome(from);
        const toCalendar = rome(to);

        // Ensure that both 'from' and 'to' calendars are in sync with each other
        if (
          !rome.val.afterEq(fromDateMoment.startOf("day"))(toCalendar.getDate())
        ) {
          toCalendar.setValue(fromDateMoment.endOf("day"));
          toCalendar.refresh();
          fromCalendar.refresh();
        }
      });

      // "To" calendar configuration
      this.toCalendar = rome(to, {
        weekStart: 1,
        time: false,
        dateValidator: rome.val.afterEq(from),
        initialValue: initialToValue.isValid() && initialToValue,
        max: moment()
      });

      if (!cancelButton.getAttribute("data-event-listener-added")) {
        cancelButton.addEventListener("click", event => {
          event.preventDefault();
          dropdownContent.classList.remove("show");
        });
        cancelButton.setAttribute("data-event-listener-added", true);
      }

      if (!applyButton.getAttribute("data-event-listener-added")) {
        applyButton.addEventListener("click", event => {
          event.preventDefault();
          const fromDate = this.fromCalendar.getMoment() || moment();
          const toDate = this.toCalendar.getMoment() || moment();
          const period = `${fromDate.format(dateFormat)} - ${toDate.format(
            dateFormat
          )}`;
          this.pushEvent("filter_by_period", { period: period });
        });
        applyButton.setAttribute("data-event-listener-added", true);
      }
    };

    this.renderDateRangePicker();
},

  updated() {
    this.fromCalendar.destroy();
    this.toCalendar.destroy();
    this.renderDateRangePicker();
  }
};


const csrfToken = document.querySelector("meta[name='csrf-token']").getAttribute("content");
const liveSocket = new LiveSocket("/live", Socket, { params: { _csrf_token: csrfToken }, hooks: Hooks });

liveSocket.connect();
