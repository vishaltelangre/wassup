defmodule WassupAppWeb.SharedView do
  use WassupAppWeb, :view

  alias WassupApp.Notes.Note

  def sentiment_details, do: Note.sentiment_details() |> Jason.encode!()

  def sentiments, do: Note.sentiment_details() |> Map.keys()
end
