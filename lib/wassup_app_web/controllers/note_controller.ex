defmodule WassupAppWeb.NoteController do
  use WassupAppWeb, :controller

  alias WassupApp.Notes
  alias WassupApp.Notes.Note

  plug :authorize_note when action in [:show, :edit, :update, :delete]

  def index(conn, _params) do
    notes = Notes.list_notes_for_user(conn.assigns.current_user.id)
    render(conn, "index.html", notes: notes)
  end

  def new(conn, _params) do
    changeset = Notes.change_note(%Note{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"note" => note_params}) do
    case Notes.create_note_for_user(conn.assigns.current_user.id, note_params) do
      {:ok, note} ->
        conn
        |> put_flash(:info, "Note created successfully.")
        |> redirect(to: Routes.note_path(conn, :show, note))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "ERORROOOR")
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => _id}) do
    # note = Notes.get_note_for_user!(conn.assigns.current_user.id, id)
    # render(conn, "show.html", note: note)
    render(conn, "show.html")
  end

  def edit(conn, %{"id" => _id}) do
    # note = Notes.get_note_for_user!(conn.assigns.current_user.id, id)
    # changeset = Notes.change_note(note)
    # render(conn, "edit.html", note: note, changeset: changeset)
    changeset = Notes.change_note(conn.assigns.note)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"id" => _id, "note" => note_params}) do
    # note = Notes.get_note_for_user!(conn.assigns.current_user.id, id)

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
    # note = Notes.get_note_for_user!(conn.assigns.current_user.id, id)
    {:ok, _note} = Notes.delete_note(conn.assigns.note)

    conn
    |> put_flash(:info, "Note deleted successfully.")
    |> redirect(to: Routes.note_path(conn, :index))
  end

  defp authorize_note(conn, _) do
    note = Notes.get_note!(conn.params["id"])

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
