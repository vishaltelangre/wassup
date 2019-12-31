defmodule WassupAppWeb.GraphController do
  use WassupAppWeb, :controller

  alias WassupApp.Notes
  alias WassupApp.PeriodOptions

  def timeline(conn, params) do
    filter = params["filter"] || %{}

    notes =
      Notes.list_notes_for_user(conn.assigns.current_user,
        period: parsed_period(conn, filter),
        q: filter["q"]
      )

    render(conn, "timeline.html", notes: notes)
  end

  defp parsed_period(conn, filter = %{}) do
    (filter["period"] || PeriodOptions.default_option())
    |> PeriodOptions.dates_for_period(conn.assigns.current_user.timezone)
  end
end
