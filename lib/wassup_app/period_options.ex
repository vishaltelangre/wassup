defmodule WassupApp.PeriodOptions do
  @options [
    "Today",
    "Yesterday",
    "Last 7 Days",
    "Last 30 Days",
    "This Month",
    "Last Month",
    "Last 3 Months",
    "This Year",
    "Last Year",
    "Last 5 Years"
  ]
  @default_option "Last 7 Days"
  @default_timezone "Etc/UTC"

  def options, do: @options

  def default_option, do: @default_option

  def today(:from, timezone) do
    Timex.today() |> Timex.to_datetime(timezone) |> Timex.beginning_of_day()
  end

  def today(:to, timezone) do
    Timex.today() |> Timex.to_datetime(timezone) |> Timex.end_of_day()
  end

  def dates_for_period(period), do: dates_for_period(period, @default_timezone)

  def dates_for_period(_period = "Today", timezone) do
    %{from: today(:from, timezone), to: today(:to, timezone)}
  end

  def dates_for_period(_period = "Yesterday", timezone) do
    from = today(:from, timezone) |> Timex.shift(days: -1)
    to = today(:to, timezone) |> Timex.shift(days: -1)

    %{from: from, to: to}
  end

  def dates_for_period(_period = "Last 7 Days", timezone) do
    from = today(:from, timezone) |> Timex.shift(days: -6)
    to = today(:to, timezone)

    %{from: from, to: to}
  end

  def dates_for_period(_period = "Last 30 Days", timezone) do
    from = today(:from, timezone) |> Timex.shift(days: -29)
    to = today(:to, timezone)

    %{from: from, to: to}
  end

  def dates_for_period(_period = "This Month", timezone) do
    from = today(:from, timezone) |> Timex.beginning_of_month()
    to = today(:to, timezone)

    %{from: from, to: to}
  end

  def dates_for_period(_period = "Last Month", timezone) do
    last_month_datetime = today(:from, timezone) |> Timex.shift(months: -1)
    from = last_month_datetime |> Timex.beginning_of_month()
    to = last_month_datetime |> Timex.end_of_month()

    %{from: from, to: to}
  end

  def dates_for_period(_period = "Last 3 Months", timezone) do
    last_3_months_datetime = today(:from, timezone) |> Timex.shift(months: -3)
    from = last_3_months_datetime |> Timex.beginning_of_month()
    to = today(:to, timezone)

    %{from: from, to: to}
  end

  def dates_for_period(_period = "This Year", timezone) do
    from = today(:from, timezone) |> Timex.beginning_of_year()
    to = today(:to, timezone) |> Timex.end_of_year()

    %{from: from, to: to}
  end

  def dates_for_period(_period = "Last Year", timezone) do
    last_year_datetime = today(:from, timezone) |> Timex.shift(years: -1)
    from = last_year_datetime |> Timex.beginning_of_year()
    to = last_year_datetime |> Timex.end_of_year()

    %{from: from, to: to}
  end

  def dates_for_period(_period = "Last 5 Years", timezone) do
    last_5_years_datetime = today(:from, timezone) |> Timex.shift(years: -5)
    from = last_5_years_datetime |> Timex.beginning_of_year()
    to = today(:to, timezone)

    %{from: from, to: to}
  end

  def dates_for_period(_period, timezone), do: dates_for_period(@default_option, timezone)

  def active_option(%{from: _from, to: _to} = dates, timezone) do
    @options
    |> Enum.find("Custom Period", fn option ->
      dates == dates_for_period(option, timezone)
    end)
  end
end
