defmodule WassupAppWeb.GraphLive.Timeline do
  use Phoenix.LiveView, layout: {WassupAppWeb.LayoutView, "live.html"}
  use WassupAppWeb.NoteLive.Shared

  alias WassupApp.Accounts
  alias WassupApp.Notes
  alias WassupApp.PeriodOptions
  alias WassupAppWeb.Endpoint
  alias WassupAppWeb.Router.Helpers, as: Routes
  alias WassupAppWeb.GraphView

  def render(assigns) do
    GraphView.render("timeline.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)

    if connected?(socket), do: Endpoint.subscribe("#{user_id}:notes")

    socket =
      socket
      |> assign_filters()
      |> assign(:current_user, current_user)
      |> assign(:note, nil)
      |> assign(:preview_note, false)

    socket = assign(socket, :notes, load_notes(socket))

    {:ok, socket}
  end

  def handle_params(params, _uri, socket) do
    filter = params["filter"] || %{}
    socket = assign_filters(socket, filter)
    socket = socket |> assign(:notes, load_notes(socket))

    {:noreply, socket}
  end

  def handle_event("criteria_change", params, socket), do: refresh(socket, params)

  def handle_event("reset_search_query", _params, socket),
    do: refresh(socket, %{"filter" => %{"q" => nil}})

  def handle_event("reset_period", _params, socket) do
    socket = assign(socket, :period_option, PeriodOptions.default_option())
    refresh(socket, %{"filter" => %{"period" => nil}})
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

    {:noreply, assign(socket, note: note, preview_note: true)}
  end

  def handle_event("close_note_preview", _value, socket),
    do: {:noreply, assign(socket, note: nil, preview_note: false)}

  def handle_info(:refresh_notes, socket), do: refresh(socket)

  defp refresh(socket, params \\ %{}) do
    {:noreply,
     live_redirect(socket,
       to:
         Routes.live_path(socket, __MODULE__, %{"filter" => filters_from_params(socket, params)})
     )}
  end

  defp filters_from_params(socket, params) do
    assigns =
      socket.assigns
      |> Map.take([:q, :period])
      |> Map.new(fn {key, value} -> {Atom.to_string(key), value} end)

    Map.merge(assigns, params["filter"] || %{})
  end

  defp assign_filters(socket, filter \\ %{}) do
    period_option =
      PeriodOptions.options()
      |> Enum.find(PeriodOptions.default_option(), fn option -> option == filter["period"] end)

    socket
    |> assign(:q, filter["q"])
    |> assign(:period_option, period_option)
  end

  defp load_notes(
         %{assigns: %{current_user: current_user, period_option: period_option, q: q}} = _socket
       ) do
    Notes.list_notes_for_user(current_user,
      period: PeriodOptions.dates_for_period(period_option, current_user.timezone),
      q: q
    )
  end

  defp update_note(socket, updated_note) do
    socket.assigns.notes
    |> Enum.map(fn note ->
      if updated_note.id == note.id,
        do: updated_note,
        else: note
    end)
  end
end
