defmodule WassupAppWeb.NoteComponent.New do
  use Phoenix.LiveComponent

  alias WassupApp.Notes
  alias WassupApp.Notes.Note

  def render(assigns) do
    WassupAppWeb.NoteView.render("new.html", assigns)
  end

  def update(assigns, socket) do
    {:ok, assign(socket, assigns)}
  end

  def mount(socket) do
    {:ok, socket}
  end

  def handle_event("validate", %{"note" => params}, socket) do
    changeset =
      %Note{}
      |> Notes.change_note(params)
      |> Map.put(:action, :insert)

    message = {:new_note_validation_result, changeset}

    broadcast!(socket, message)

    {:noreply, socket}
  end

  def handle_event("save", %{"note" => params}, socket) do
    case Notes.create_note_for_user(socket.assigns.current_user.id, params) do
      {:ok, _} ->
        broadcast!(socket, :note_created)

      {:error, %Ecto.Changeset{} = changeset} ->
        broadcast!(socket, {:new_note_validation_result, changeset})
    end

    {:noreply, socket}
  end

  defp broadcast!(socket, message) do
    topic = user_dashboard_topic(socket)

    Phoenix.PubSub.broadcast!(WassupApp.PubSub, topic, message)
  end

  defp user_dashboard_topic(socket) do
    socket.assigns.current_user.id <> ":dashboard"
  end
end
