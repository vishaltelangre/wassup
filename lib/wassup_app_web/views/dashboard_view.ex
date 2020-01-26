defmodule WassupAppWeb.DashboardView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView,
    only: [
      note_favorite_icon_link: 1,
      formatted_datetime: 1
    ]

  def truncated_note_body_with_more_link(note, max_length) do
    elipsis =
      if String.length(note.body) > max_length do
        link("…",
          to: {:javascript, "void(0)"},
          "phx-click": "preview_note",
          "phx-value-note-id": note.id
        )
      else
        ""
      end

    content_tag(:span) do
      [
        {:safe, String.slice(note.body, 0..max_length)},
        elipsis
      ]
    end
  end
end
