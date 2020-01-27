defmodule WassupAppWeb.NoteView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView,
    only: [
      sentiments: 0,
      present?: 1,
      note_favorite_icon_link: 1,
      formatted_datetime: 1
    ]

  import WassupAppWeb.PaginateView, only: [pagination_links: 3]

  alias WassupApp.PeriodOptions

  def period_option_links(socket) do
    PeriodOptions.options()
    |> Enum.map(fn option -> period_option_link(socket, option) end)
    |> Enum.concat([custom_period_option_link(socket)])
  end

  defp period_option_link(
         %{assigns: %{active_period_option: active_period_option}} = _socket,
         option
       ) do
    link(option,
      to: {:javascript, "void(0)"},
      class: "daterange-filter #{period_option_active_class(option, active_period_option)}",
      phx_click: "filter_by_period_option",
      phx_value_option: option
    )
  end

  defp custom_period_option_link(socket) do
    link("Custom Period",
      to: {:javascript, "void(0)"},
      class:
        "daterange-filter " <>
          period_option_active_class("Custom Period", socket.assigns.active_period_option)
    )
  end

  defp period_option_active_class(option, active_option),
    do: if(option == active_option, do: "active", else: "")
end
