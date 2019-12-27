defmodule WassupAppWeb.NoteController do
  use WassupAppWeb, :controller

  alias WassupApp.Notes
  alias WassupAppWeb.NoteChannel
  alias WassupAppWeb.ErrorView

  plug :authorize_note when action in [:edit, :update, :delete, :toggle_favorite]

  def index(conn, params) do
    %{data: data, paginate: paginate} =
      Notes.paginate_notes_for_user(conn.assigns.current_user, params["filter"] || %{})

    render(conn, "index.html", notes: data, paginate: paginate)
  end

  def create(conn, %{"note" => note_params}) do
    case Notes.create_note_for_user(conn.assigns.current_user.id, note_params) do
      {:ok, _} ->
        NoteChannel.broadcast_refresh(conn.assigns.current_user.id)

        json(conn, %{})

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> render(ErrorView, "error.json", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => _id}) do
    changeset = Notes.change_note(conn.assigns.note)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => _id, "note" => note_params}) do
    case Notes.update_note(conn.assigns.note, note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note updated successfully.")
        |> redirect(to: Routes.note_path(conn, :show, note))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def delete(conn, %{"id" => _id}) do
    {:ok, _note} = Notes.delete_note(conn.assigns.note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: Routes.note_path(conn, :index))
  end

  def toggle_favorite(conn, %{"note_id" => _id, "favorite" => favorite}) do
    case Notes.update_note(conn.assigns.note, %{favorite: favorite}) do
      {:ok, note} ->
        NoteChannel.broadcast_refresh(conn.assigns.current_user.id)

        json(conn, note)

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_status(:unprocessable_entity)
        |> json(%{error: "An error occurred"})
    end
  end

  defp authorize_note(conn, _) do
    note = Notes.get_note!(conn.params["id"] || conn.params["note_id"])

    if conn.assigns.current_user.id == note.user_id do
      assign(conn, :note, note)
    else
      conn
      |> put_flash(:error, "You don't have access for that note")
      |> redirect(to: "/")
      |> halt()
    end
  end
end
