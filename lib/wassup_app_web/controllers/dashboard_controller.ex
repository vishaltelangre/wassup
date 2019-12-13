defmodule WassupAppWeb.DashboardController do
  use WassupAppWeb, :controller

  alias WassupApp.{Notes, Notes.Note}

  def index(conn, _params) do
    notes =
      Notes.list_notes_for_user(conn.assigns.current_user.id, order_by: [asc: :submitted_at])
      |> Enum.map(fn %{sentiment: sentiment} = notes ->
        %{notes | sentiment: Note.sentiment_details()[sentiment][:value]}
      end)
      |> Jason.encode!()

    render(
      conn,
      "index.html",
      notes: notes,
      sentiment_details: Note.sentiment_details() |> Jason.encode!()
    )
  end
end
