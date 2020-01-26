defmodule WassupAppWeb.SharedView do
  use WassupAppWeb, :view

  alias WassupApp.Notes.Note

  def sentiment_details, do: Note.sentiment_details() |> Jason.encode!()

  def sentiments, do: Note.sentiment_details() |> Map.keys()

  def present?(value) do
    !(value == nil || String.length(String.trim(value)) == 0)
  end

  def note_favorite_icon_link(note) do
    link(
      to: {:javascript, "void(0)"},
      class: "icon-wrapper",
      "phx-click": "toggle_note_favorite",
      "phx-value-note-id": note.id,
      "phx-value-favorite": "#{!note.favorite}"
    ) do
      img_tag(note.favorite_icon_path, class: "icon star-icon")
    end
  end

  def formatted_datetime(datetime) do
    Timex.format!(datetime, "%B %d, %Y - %I:%M:%S %p", :strftime)
  end
end
