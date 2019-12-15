defmodule WassupAppWeb.LayoutView do
  use WassupAppWeb, :view

  alias WassupApp.Notes.Note

  def sentiment_details, do: Note.sentiment_details() |> Jason.encode!()
end
