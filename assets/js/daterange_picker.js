import rome from "@bevacqua/rome";

const { moment } = rome;
const dateRangePickerSelector = "[data-behavior=daterange-picker]";
const fromCalendarSelector = "[data-behavior=daterange-picker-from-calendar]";
const toCalendarSelector = "[data-behavior=daterange-picker-to-calendar]";
const valueFieldSelector = "[data-behavior=value]";
const applyButtonSelector = "[data-behavior=apply-daterange]";
const cancelButtonSelector = "[data-behavior=cancel-daterange]";
const todayFilterSelector = "[data-behavior=today-filter]";
const yesterdayFilterSelector = "[data-behavior=yesterday-filter]";
const lastSevenDaysFilterSelector = "[data-behavior=last-7-days-filter]";
const lastThirtyDaysFilterSelector = "[data-behavior=last-30-days-filter]";
const thisMonthFilterSelector = "[data-behavior=this-month-filter]";
const lastMonthFilterSelector = "[data-behavior=last-month-filter]";
const lastThreeMonthsFilterSelector = "[data-behavior=last-3-months-filter]";
const thisYearFilterSelector = "[data-behavior=this-year-filter]";
const lastYearFilterSelector = "[data-behavior=last-year-filter]";
const lastFiveYearsFilterSelector = "[data-behavior=last-5-years-filter]";
const customPeriodFilterSelector = "[data-behavior=custom-period-filter]";
const dateFormat = "MMM D, YYYY";

const isToday = (from, to) =>
  from.format(dateFormat) === to.format(dateFormat)
    && from.format(dateFormat) === moment().format(dateFormat);

const isYesterday = (from, to) =>
  from.format(dateFormat) === to.format(dateFormat)
    && from.format(dateFormat) === moment().subtract(1, 'days').format(dateFormat);

const isLastSevenDaysPeriod = (from, to) =>
  from.format(dateFormat) === moment().subtract(6, 'days').format(dateFormat)
    && to.format(dateFormat) === moment().format(dateFormat);

const isLastThirtyDaysPeriod = (from, to) =>
  from.format(dateFormat) === moment().subtract(29, 'days').format(dateFormat)
    && to.format(dateFormat) === moment().format(dateFormat);

const isThisMonthPeriod = (from, to) =>
  from.format(dateFormat) === moment().startOf('month').format(dateFormat)
    && to.format(dateFormat) === moment().format(dateFormat);

const isLastMonthPeriod = (from, to) =>
  from.format(dateFormat) === moment().subtract(1, 'months').startOf('month').format(dateFormat)
    && to.format(dateFormat) === moment().subtract(1, 'months').endOf('month').format(dateFormat);

const isLastThreeMonthsPeriod = (from, to) =>
  from.format(dateFormat) === moment().subtract(3, 'months').startOf('month').format(dateFormat)
    && to.format(dateFormat) === moment().format(dateFormat);

const isThisYearPeriod = (from, to) =>
  from.format(dateFormat) === moment().startOf('year').format(dateFormat)
    && to.format(dateFormat) === moment().format(dateFormat);

const isLastYearPeriod = (from, to) =>
  from.format(dateFormat) === moment().subtract(1, 'years').startOf('year').format(dateFormat)
    && to.format(dateFormat) === moment().subtract(1, 'years').endOf('year').format(dateFormat);

const isLastFiveYearsPeriod = (from, to) =>
  from.format(dateFormat) === moment().subtract(5, 'years').startOf('year').format(dateFormat)
    && to.format(dateFormat) === moment().format(dateFormat);

document.addEventListener('DOMContentLoaded', () => {
  const daterangePickers = document.querySelectorAll(dateRangePickerSelector);

  for (let daterangePicker of daterangePickers) {
    const pickerChild = selector => daterangePicker.querySelector(selector);
    const from = pickerChild(fromCalendarSelector);
    const to = pickerChild(toCalendarSelector);
    const getValueField = () => pickerChild(valueFieldSelector);
    const value = getValueField().value || "";
    const [rawInitialFromValue, rawInitialToValue] = value.trim().split('-');
    const initialFromValue = moment(rawInitialFromValue.trim(), dateFormat);
    const initialToValue = moment((rawInitialToValue || "").trim(), dateFormat);

    pickerChild(applyButtonSelector).addEventListener('click', () => {
      const fromDate = rome(from).getMoment() || moment();
      const toDate = rome(to).getMoment() || moment()
      getValueField().value = `${fromDate.format(dateFormat)} - ${toDate.format(dateFormat)}`;
    });

    pickerChild(cancelButtonSelector).addEventListener('click', event => {
      event.preventDefault();
      pickerChild('[data-behavior=dropdown-content]').classList.remove('show');
    });

    const applyFilter = (from, to) => {
      const valueField = getValueField();
      valueField.value = `${from} - ${to}`;
      valueField.onchange();
    };

    // Handle click on 'Today' filter
    pickerChild(todayFilterSelector).addEventListener('click', () => {
      const from = moment().format(dateFormat);
      const to = from;
      applyFilter(from, to);
    });

    // Handle click on 'Yesterday' filter
    pickerChild(yesterdayFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(1, 'days').format(dateFormat);
      const to = from;
      applyFilter(from, to);
    });

    // Handle click on 'Last 7 Days' filter
    pickerChild(lastSevenDaysFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(6, 'days').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last 30 Days' filter
    pickerChild(lastThirtyDaysFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(29, 'days').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'This Month' filter
    pickerChild(thisMonthFilterSelector).addEventListener('click', () => {
      const from = moment().startOf('month').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last Month' filter
    pickerChild(lastMonthFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(1, 'months').startOf('month').format(dateFormat);
      const to = moment().subtract(1, 'months').endOf('month').format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last 3 Months' filter
    pickerChild(lastThreeMonthsFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(3, 'months').startOf('month').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'This Year' filter
    pickerChild(thisYearFilterSelector).addEventListener('click', () => {
      const from = moment().startOf('year').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last Year' filter
    pickerChild(lastYearFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(1, 'years').startOf('year').format(dateFormat);
      const to = moment().subtract(1, 'years').endOf('year').format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last 5 Years' filter
    pickerChild(lastFiveYearsFilterSelector).addEventListener('click', () => {
      const from = moment().subtract(5, 'years').startOf('year').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    const setFilterActive = filterSelector => pickerChild(filterSelector).classList.add('active');

    if (isToday(initialFromValue, initialToValue)) {
      setFilterActive(todayFilterSelector);
    } else if (isYesterday(initialFromValue, initialToValue)) {
      setFilterActive(yesterdayFilterSelector);
    } else if (isLastSevenDaysPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastSevenDaysFilterSelector);
    } else if (isLastThirtyDaysPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastThirtyDaysFilterSelector);
    } else if (isThisMonthPeriod(initialFromValue, initialToValue)) {
      setFilterActive(thisMonthFilterSelector);
    } else if (isLastMonthPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastMonthFilterSelector);
    } else if (isLastThreeMonthsPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastThreeMonthsFilterSelector);
    } else if (isThisYearPeriod(initialFromValue, initialToValue)) {
      setFilterActive(thisYearFilterSelector);
    } else if (isLastYearPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastYearFilterSelector);
    } else if (isLastFiveYearsPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastFiveYearsFilterSelector);
    } else {
      setFilterActive(customPeriodFilterSelector);
    }

    // "From" calendar configuration
    rome(from, {
      weekStart: 1,
      time: false,
      dateValidator: rome.val.beforeEq(to),
      max: moment(),
      initialValue: initialFromValue.isValid() && initialFromValue
    }).on('data', fromDate => {
      const fromDateMoment = moment(fromDate);
      const fromCalendar = rome(from);
      const toCalendar = rome(to);

      // Ensure that both 'from' and 'to' calendars are in sync with each other
      if (!rome.val.afterEq(fromDateMoment.startOf('day'))(toCalendar.getDate())) {
        toCalendar.setValue(fromDateMoment.endOf('day'));
        toCalendar.refresh();
        fromCalendar.refresh();
      }
    });

    // "To" calendar configuration
    rome(to, {
      weekStart: 1,
      time: false,
      dateValidator: rome.val.afterEq(from),
      initialValue: initialToValue.isValid() && initialToValue,
      max: moment()
    });
  }
});
