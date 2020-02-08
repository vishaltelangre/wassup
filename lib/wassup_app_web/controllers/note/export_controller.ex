defmodule WassupAppWeb.Note.ExportController do
  use WassupAppWeb, :controller

  alias WassupApp.Notes
  alias WassupAppWeb.SharedView

  def csv(conn, _params) do
    case Briefly.create() do
      {:ok, path} ->
        csv_headers()
        |> Stream.concat(data(conn) |> Stream.map(&csv_row_contents/1))
        |> CSV.encode()
        |> Enum.into(File.stream!(path, encoding: :utf8))

        send_download(conn, {:file, path}, charset: "utf-8", filename: "wassup-notes.csv")

      _ ->
        render_csv_download_failed(conn)
    end
  end

  defp csv_row_contents(note) do
    [
      note.submitted_at |> SharedView.formatted_datetime(),
      note.body |> String.replace("\r\n", " "),
      note.sentiment |> to_string() |> String.capitalize(),
      note.favorite |> if(do: "Yes", else: "No")
    ]
  end

  defp csv_headers, do: [["Submitted At", "Note", "Sentiment", "Starred?"]]

  defp data(%{assigns: %{current_user: current_user}} = _conn),
    do: Notes.list_notes_for_user(current_user, order_by: [asc: :submitted_at])

  defp render_csv_download_failed(conn),
    do: conn |> send_resp(500, "CSV download failed.")
end
