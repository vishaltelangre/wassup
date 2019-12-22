import rome from "@bevacqua/rome";

const { moment } = rome;
const daterangePickerClassName = "daterange-picker";
const fromCalendarClassName = "from";
const toCalendarClassName = "to";
const valueFieldClassName = "value";
const applyButtonClassName = "apply";
const cancelButtonClassName = "cancel";
const todayFilterClassName = "today";
const yesterdayFilterClassName = "yesterday";
const lastSevenDaysFilterClassName = "last-7-days";
const lastThirtyDaysFilterClassName = "last-30-days";
const thisMonthFilterClassName = "this-month";
const lastMonthFilterClassName = "last-month";
const lastThreeMonthsFilterClassName = "last-3-months";
const thisYearFilterClassName = "this-year";
const lastYearFilterClassName = "last-year";
const lastFiveYearsFilterClassName = "last-5-years";
const customPeriodFilterClassName = "custom-period";
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
  const daterangePickers = document.getElementsByClassName(daterangePickerClassName);

  for (let daterangePicker of daterangePickers) {
    const pickerChild = selector => daterangePicker.querySelector(selector);
    const from = pickerChild(`.${fromCalendarClassName}`);
    const to = pickerChild(`.${toCalendarClassName}`);
    const getValueField = () => pickerChild(`.${valueFieldClassName}`);
    const value = getValueField().value || "";
    const [rawInitialFromValue, rawInitialToValue] = value.trim().split('-');
    const initialFromValue = moment(rawInitialFromValue.trim(), dateFormat);
    const initialToValue = moment((rawInitialToValue || "").trim(), dateFormat);

    pickerChild(`.${applyButtonClassName}`).addEventListener('click', () => {
      const fromDate = rome(from).getMoment() || moment();
      const toDate = rome(to).getMoment() || moment()
      getValueField().value = `${fromDate.format(dateFormat)} - ${toDate.format(dateFormat)}`;
    });

    pickerChild(`.${cancelButtonClassName}`).addEventListener('click', event => {
      event.preventDefault();
      pickerChild('.dropdown-content').classList.remove('show');
    });

    const applyFilter = (from, to) => {
      const valueField = getValueField();
      valueField.value = `${from} - ${to}`;
      valueField.onchange();
    };

    // Handle click on 'Today' filter
    pickerChild(`.${todayFilterClassName}`).addEventListener('click', () => {
      const from = moment().format(dateFormat);
      const to = from;
      applyFilter(from, to);
    });

    // Handle click on 'Yesterday' filter
    pickerChild(`.${yesterdayFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(1, 'days').format(dateFormat);
      const to = from;
      applyFilter(from, to);
    });

    // Handle click on 'Last 7 Days' filter
    pickerChild(`.${lastSevenDaysFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(6, 'days').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last 30 Days' filter
    pickerChild(`.${lastThirtyDaysFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(29, 'days').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'This Month' filter
    pickerChild(`.${thisMonthFilterClassName}`).addEventListener('click', () => {
      const from = moment().startOf('month').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last Month' filter
    pickerChild(`.${lastMonthFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(1, 'months').startOf('month').format(dateFormat);
      const to = moment().subtract(1, 'months').endOf('month').format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last 3 Months' filter
    pickerChild(`.${lastThreeMonthsFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(3, 'months').startOf('month').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'This Year' filter
    pickerChild(`.${thisYearFilterClassName}`).addEventListener('click', () => {
      const from = moment().startOf('year').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last Year' filter
    pickerChild(`.${lastYearFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(1, 'years').startOf('year').format(dateFormat);
      const to = moment().subtract(1, 'years').endOf('year').format(dateFormat);
      applyFilter(from, to);
    });

    // Handle click on 'Last 5 Years' filter
    pickerChild(`.${lastFiveYearsFilterClassName}`).addEventListener('click', () => {
      const from = moment().subtract(5, 'years').startOf('year').format(dateFormat);
      const to = moment().format(dateFormat);
      applyFilter(from, to);
    });

    const setFilterActive = filterClassName => pickerChild(`.${filterClassName}`).classList.add('active');

    if (isToday(initialFromValue, initialToValue)) {
      setFilterActive(todayFilterClassName);
    } else if (isYesterday(initialFromValue, initialToValue)) {
      setFilterActive(yesterdayFilterClassName);
    } else if (isLastSevenDaysPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastSevenDaysFilterClassName);
    } else if (isLastThirtyDaysPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastThirtyDaysFilterClassName);
    } else if (isThisMonthPeriod(initialFromValue, initialToValue)) {
      setFilterActive(thisMonthFilterClassName);
    } else if (isLastMonthPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastMonthFilterClassName);
    } else if (isLastThreeMonthsPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastThreeMonthsFilterClassName);
    } else if (isThisYearPeriod(initialFromValue, initialToValue)) {
      setFilterActive(thisYearFilterClassName);
    } else if (isLastYearPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastYearFilterClassName);
    } else if (isLastFiveYearsPeriod(initialFromValue, initialToValue)) {
      setFilterActive(lastFiveYearsFilterClassName);
    } else {
      setFilterActive(customPeriodFilterClassName);
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
