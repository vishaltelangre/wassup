defmodule WassupAppWeb.NoteLive.Index do
  use Phoenix.LiveView, layout: {WassupAppWeb.LayoutView, "live.html"}
  use WassupAppWeb.NoteLive.Shared

  alias WassupApp.Accounts
  alias WassupApp.Notes
  alias WassupApp.PeriodOptions
  alias WassupAppWeb.Endpoint
  alias WassupAppWeb.Router.Helpers, as: Routes

  @period_date_display_format "%b %d, %Y"
  @default_active_period_option "Custom Period"

  def render(assigns) do
    WassupAppWeb.NoteView.render("index.html", assigns)
  end

  def mount(_params, %{"user_id" => user_id}, socket) do
    current_user = Accounts.get_user!(user_id)
    %{data: notes, paginate: paginate} = paginate_notes_for_user(current_user)

    if connected?(socket), do: Endpoint.subscribe("#{user_id}:notes")

    socket =
      socket
      |> assign_filters(%{})
      |> assign(:notes, notes)
      |> assign(:paginate, paginate)
      |> assign(:current_user, current_user)
      |> assign(:edit_note_changeset, nil)
      |> assign(:note, nil)
      |> assign(:active_period_option, @default_active_period_option)

    {:ok, socket}
  end

  def handle_params(params, _uri, %{assigns: %{current_user: current_user}} = socket) do
    filter = params["filter"] || %{}
    %{data: notes, paginate: paginate} = paginate_notes_for_user(current_user, filter)

    socket =
      socket
      |> assign_filters(filter)
      |> assign(:notes, notes)
      |> assign(:paginate, paginate)

    {:noreply, socket}
  end

  def handle_event("criteria_change", params, socket), do: refresh(socket, params)

  def handle_event("reset_search_query", _params, socket),
    do: refresh(socket, %{"filter" => %{"q" => nil}})

  # Filter by period option such as "Last Month"
  def handle_event("filter_by_period_option", %{"option" => option}, socket) do
    timezone = socket.assigns.current_user.timezone
    dates = PeriodOptions.dates_for_period(option, timezone)
    from_string = Timex.format!(dates.from, @period_date_display_format, :strftime)
    to_string = Timex.format!(dates.to, @period_date_display_format, :strftime)
    period = from_string <> " - " <> to_string

    socket = update_active_period_option_assign(socket, dates, timezone)

    refresh(socket, %{"filter" => %{"period" => period}})
  end

  # Filter by period such as "Dec 14, 2019 - Dec 31, 2019"
  def handle_event("filter_by_period", %{"period" => period}, socket) do
    timezone = socket.assigns.current_user.timezone

    [from, to] =
      String.split(period, "-", trim: true) |> Enum.map(&parse_period_date(&1, timezone))

    dates = %{from: Timex.beginning_of_day(from), to: Timex.end_of_day(to)}
    socket = update_active_period_option_assign(socket, dates, timezone)

    refresh(socket, %{"filter" => %{"period" => period}})
  end

  defp parse_period_date(date, timezone) do
    String.trim(date)
    |> Timex.parse!(@period_date_display_format, :strftime)
    |> Timex.to_datetime(timezone)
  end

  defp update_active_period_option_assign(socket, dates, timezone) do
    assign(socket, :active_period_option, PeriodOptions.active_option(dates, timezone))
  end

  def handle_event("reset_period", _params, socket) do
    socket = assign(socket, :active_period_option, @default_active_period_option)
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

    {:noreply, socket}
  end

  def handle_info(:refresh_notes, socket), do: refresh(socket)

  defp refresh(socket, params \\ %{}) do
    {:noreply,
     live_redirect(socket,
       to:
         Routes.live_path(socket, __MODULE__, %{"filter" => filters_from_params(socket, params)})
     )}
  end

  defp paginate_notes_for_user(user, filter \\ %{}),
    do: Notes.paginate_notes_for_user(user, filter)

  defp assign_filters(socket, filter \\ %{}) do
    socket
    |> assign(:q, filter["q"])
    |> assign(:period, filter["period"])
    |> assign(:page, filter["page"] || 1)
    |> assign(:per_page, filter["per_page"] || 10)
  end

  defp filters_from_params(socket, params) do
    assigns =
      socket.assigns
      |> Map.take([:q, :period, :page, :per_page])
      |> Map.new(fn {key, value} -> {Atom.to_string(key), value} end)

    filters = params["filter"] || %{}

    # If 'page' filter is not changed, it means some other filter is changed.
    # Therefore, we will reset the 'page' filter to 1.
    filters =
      if assigns["page"] == (filters["page"] || assigns["page"]) do
        Map.put(filters, "page", 1)
      else
        filters
      end

    Map.merge(assigns, filters)
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
