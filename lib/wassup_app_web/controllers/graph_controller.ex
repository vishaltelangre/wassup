defmodule WassupAppWeb.GraphController do
  use WassupAppWeb, :controller

  alias WassupApp.{Notes, Notes.Note}
  alias WassupApp.PeriodOptions

  def timeline(conn, params) do
    filter = params["filter"] || %{}

    period =
      (filter["period"] || PeriodOptions.default_option()) |> PeriodOptions.dates_for_period()

    q = filter["q"]

    notes =
      Notes.list_notes_for_user(conn.assigns.current_user.id, period: period, q: q)
      |> Enum.map(fn note ->
        %{note | sentiment: Note.sentiment_value(note.sentiment)}
      end)

    render(conn, "timeline.html", notes: notes)
  end
end
