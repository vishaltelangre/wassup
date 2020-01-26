defmodule WassupAppWeb.DashboardLive do
  use Phoenix.LiveView, layout: {WassupAppWeb.LayoutView, "live.html"}
  use WassupAppWeb.NoteLive.Shared

  alias WassupApp.Accounts
  alias WassupApp.Notes
  alias WassupApp.Notes.Note
  alias WassupAppWeb.Endpoint
  alias WassupAppWeb.DashboardView

  def render(assigns) do
    DashboardView.render("index.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)

    register_callbacks(socket, user_id)

    notes = notes_for_user(current_user)

    socket =
      socket
      |> assign(:current_user, current_user)
      |> assign(:notes, notes)
      |> assign(:notes_count, Enum.count(notes))
      |> assign(:note, nil)
      |> assign(:preview_note, false)
      |> assign(:new_note_changeset, reset_new_note_changeset())
      |> assign(:edit_note_changeset, nil)

    {:ok, socket}
  end

  defp register_callbacks(socket, user_id) do
    if connected?(socket) do
      :timer.send_interval(30000, self(), :refresh_notes)

      Endpoint.subscribe("#{user_id}:dashboard")
    end
  end

  def handle_event(
        "toggle_note_favorite",
        %{"note-id" => note_id, "favorite" => favorite},
        %{assigns: %{current_user: current_user}} = socket
      ) do
    {:ok, note} =
      Notes.update_note_for_user(current_user, Notes.get_note!(note_id), %{favorite: favorite})

    broadcast!(socket, {:note_favorite_updated, note})

    {:noreply, assign(socket, :preview_note, socket.assigns.preview_note)}
  end

  def handle_event("preview_note", %{"note-id" => note_id}, socket) do
    note = Notes.get_note_for_user!(socket.assigns.current_user, note_id)

    {:noreply, assign(socket, note: note, preview_note: true, edit_note_changeset: nil)}
  end

  def handle_event("close_note_preview", _value, socket),
    do: {:noreply, assign(socket, note: nil, preview_note: false)}

  def handle_info({:new_note_validation_result, %Ecto.Changeset{} = changeset}, socket),
    do: {:noreply, assign(socket, :new_note_changeset, changeset)}

  def handle_info(:note_created, socket) do
    broadcast!(socket, :refresh_notes)

    {:noreply, assign(socket, new_note_changeset: reset_new_note_changeset())}
  end

  def handle_info(:refresh_notes, socket) do
    notes = notes_for_user(socket.assigns.current_user)

    socket =
      socket
      |> assign(:notes, notes)
      |> assign(:notes_count, Enum.count(notes))

    {:noreply, socket}
  end

  defp notes_for_user(user),
    do:
      Notes.list_notes_for_user(user, limit: 7)
      |> Enum.map(&add_relative_submitted_at_to_note/1)

  defp update_note(socket, updated_note) do
    socket.assigns.notes
    |> Enum.map(fn note ->
      if updated_note.id == note.id,
        do: add_relative_submitted_at_to_note(updated_note),
        else: note
    end)
  end

  defp add_relative_submitted_at_to_note(note),
    do:
      Map.put(
        note,
        :relative_submitted_at,
        Timex.format!(note.submitted_at, "{relative}", :relative)
      )

  defp reset_new_note_changeset, do: Notes.change_note(%Note{sentiment: :happy})
end
