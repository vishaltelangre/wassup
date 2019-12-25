defmodule WassupAppWeb.NoteChannel do
  use WassupAppWeb, :channel

  alias WassupApp.{Notes, Notes.Note}
  alias WassupApp.Accounts

  def join("note:dashboard:" <> user_id, _message, socket) do
    if user_id == socket.assigns.current_user do
      {:ok, refresh_event_response(user_id), socket}
    else
      {:error, %{reason: "unauthorized"}}
    end
  end

  def join("note:" <> _, _message, _) do
    {:error, %{reason: "Unknown channel"}}
  end

  def handle_in("refresh", _body, socket) do
    broadcast!(socket, "refresh", refresh_event_response(socket.assigns.current_user))
    {:noreply, socket}
  end

  def broadcast_refresh(user_id) do
    WassupAppWeb.Endpoint.broadcast!(
      "note:dashboard:#{user_id}",
      "refresh",
      refresh_event_response(user_id)
    )
  end

  defp refresh_event_response(user_id) do
    %{body: latest_user_notes(user_id)}
  end

  defp latest_user_notes(user_id) do
    Accounts.get_user!(user_id)
    |> Notes.list_notes_for_user(limit: 7)
    |> Jason.encode!()
  end
end
