defmodule WassupAppWeb.NoteLive.Shared do
  defmacro __using__(_opts) do
    quote do
      alias Phoenix.PubSub
      alias WassupApp.Notes
      alias WassupApp.Notes.Note

      def handle_info({:edit_note_validation_result, %Ecto.Changeset{} = changeset}, socket) do
        {:noreply, assign(socket, :edit_note_changeset, changeset)}
      end

      def handle_info(
            {:note_updated, %Note{} = updated_note},
            %{assigns: %{edit_note_changeset: edit_note_changeset}} = socket
          ) do
        socket =
          if edit_note_changeset && edit_note_changeset.data.id == updated_note.id do
            assign(socket, edit_note_changeset: nil)
          else
            assign(socket, :edit_note_changeset, edit_note_changeset)
          end

        handle_note_updated(updated_note, socket)
      end

      def handle_info({:note_updated, %Note{} = updated_note}, socket),
        do: handle_note_updated(updated_note, socket)

      def handle_info({:note_favorite_updated, %Note{} = updated_note}, socket),
        do: handle_note_updated(updated_note, socket)

      defp handle_note_updated(updated_note, %{assigns: %{note: note}} = socket) do
        socket =
          if note && note.id == updated_note.id,
            do: assign(socket, :note, updated_note),
            else: socket

        socket = assign(socket, :notes, update_note(socket, updated_note))

        {:noreply, socket}
      end

      def handle_info({:note_deleted, note_id}, %{assigns: %{note: note}} = socket) do
        socket = if note && note.id == note_id, do: assign(socket, :note, nil), else: socket

        send(self(), :refresh_notes)

        {:noreply, socket}
      end

      def handle_event("edit_note", %{"note-id" => note_id}, socket) do
        note = Notes.get_note_for_user!(socket.assigns.current_user, note_id)

        socket =
          socket
          |> assign(:note, note)
          |> assign(:edit_note_changeset, Notes.change_note(note))

        {:noreply, socket}
      end

      def handle_event("cancel_editing_note", _value, socket),
        do: {:noreply, assign(socket, note: nil, edit_note_changeset: nil)}

      def handle_event("delete_note", %{"note-id" => note_id}, socket) do
        {:ok, _} =
          Notes.get_note_for_user!(socket.assigns.current_user, note_id)
          |> Notes.delete_note()

        broadcast!(socket, {:note_deleted, note_id})

        {:noreply, socket}
      end

      defp broadcast!(socket, message) do
        [user_dashboard_topic(socket), user_notes_topic(socket)]
        |> Enum.map(fn topic ->
          PubSub.broadcast!(WassupApp.PubSub, topic, message)
        end)
      end

      defp user_dashboard_topic(socket), do: socket.assigns.current_user.id <> ":dashboard"

      defp user_notes_topic(socket), do: socket.assigns.current_user.id <> ":notes"
    end
  end
end
