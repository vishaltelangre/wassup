defmodule WassupAppWeb.NoteComponent.Edit do
  use Phoenix.LiveComponent

  alias WassupApp.Notes

  def render(assigns) do
    WassupAppWeb.NoteView.render("edit.html", assigns)
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"note" => params}, socket) do
    changeset =
      socket.assigns.note
      |> Notes.change_note(params)
      |> Map.put(:action, :update)

    send(self(), {:edit_note_validation_result, changeset})

    {:noreply, socket}
  end

  def handle_event("save", %{"note" => params}, socket) do
    %{assigns: %{current_user: current_user, note: note}} = socket

    case Notes.update_note_for_user(current_user, note, params) do
      {:ok, note} ->
        broadcast!(socket, {:note_updated, note})

      {:error, %Ecto.Changeset{} = changeset} ->
        broadcast!(socket, {:edit_note_validation_result, changeset})
    end

    {:noreply, socket}
  end

  defp broadcast!(socket, message) do
    [user_dashboard_topic(socket), user_notes_topic(socket)]
    |> Enum.map(fn topic ->
      Phoenix.PubSub.broadcast!(WassupApp.PubSub, topic, message)
    end)
  end

  defp user_dashboard_topic(socket), do: socket.assigns.current_user.id <> ":dashboard"

  defp user_notes_topic(socket), do: socket.assigns.current_user.id <> ":notes"
end
