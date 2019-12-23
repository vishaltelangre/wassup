defmodule WassupAppWeb.NoteView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [sentiments: 0, reset_filter_path: 2, filter_present?: 2]
  import WassupAppWeb.PaginateView, only: [pagination_links: 3]

  alias WassupApp.PeriodOptions

  def period_option_links(conn) do
    PeriodOptions.options() |> Enum.map(fn option -> period_option_link(conn, option) end)
  end

  def period_option_link(conn, option) do
    class =
      option |> to_string |> String.trim() |> String.downcase() |> String.replace(~r/\s+/, "-")

    link(option, to: {:javascript, "void(0)"}, class: class)
  end
end
