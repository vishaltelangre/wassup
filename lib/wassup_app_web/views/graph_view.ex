defmodule WassupAppWeb.GraphView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [reset_filter_path: 2, filter_present?: 2]
  alias WassupApp.PeriodOptions

  def period_filter_value(conn) do
    filter = conn.params["filter"]["period"]

    if Enum.member?(PeriodOptions.options(), filter),
      do: filter,
      else: PeriodOptions.default_option()
  end

  def period_option_links(conn) do
    PeriodOptions.options() |> Enum.map(fn option -> period_option_link(conn, option) end)
  end

  def period_option_link(conn, option) do
    active_class = if period_filter_value(conn) == option, do: "active", else: ""

    link(option,
      to:
        {:javascript,
         "var e = document.querySelector('.period .value'); e.value='#{option}'; e.onchange();"},
      class: "option #{active_class}"
    )
  end
end
