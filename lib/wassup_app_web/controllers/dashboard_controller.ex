defmodule WassupAppWeb.DashboardController do
  use WassupAppWeb, :controller

  alias WassupApp.{Notes, Notes.Note}

  def index(conn, _params) do
    changeset = Notes.change_note(%Note{})
    notes = Notes.list_notes_for_user(conn.assigns.current_user.id, limit: 7)
    render(conn, "index.html", changeset: changeset, notes: notes)
  end
end
