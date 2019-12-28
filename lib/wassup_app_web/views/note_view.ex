defmodule WassupAppWeb.NoteView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [sentiments: 0, reset_filter_path: 2, filter_present?: 2]
  import WassupAppWeb.PaginateView, only: [pagination_links: 3]

  alias WassupApp.PeriodOptions
  alias WassupApp.Notes.Note

  def period_option_links(conn) do
    PeriodOptions.options() |> Enum.map(fn option -> period_option_link(conn, option) end)
  end

  def period_option_link(_conn, option) do
    dasherized_option =
      option
      |> to_string
      |> String.trim()
      |> String.downcase()
      |> String.replace(~r/\s+/, "-")

    link(option,
      to: {:javascript, "void(0)"},
      class: "daterange-filter",
      data: [behavior: "#{dasherized_option}-filter"]
    )
  end

  def note_favorite_toggle_link(conn, %Note{
        id: id,
        favorite: favorite,
        favorite_icon_path: favorite_icon_path
      }) do
    title = if(favorite, do: "Unstar this note", else: "Star this note")

    link to: {:javascript, "void(0)"},
         title: title,
         class: "icon-wrapper",
         data: [behavior: "note-favorite-toggle", note_id: id, toggle_to: !favorite] do
      img_tag(Routes.static_path(conn, favorite_icon_path), class: "icon star-icon")
    end
  end
end
