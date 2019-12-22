defmodule WassupAppWeb.NoteView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [sentiments: 0]
  import WassupAppWeb.PaginateView, only: [pagination_links: 3]

  def reset_filter_path(conn = %Plug.Conn{}, filter_name) do
    conn |> reset_filter_path(filter_name, conn.params["filter"])
  end

  def reset_filter_path(conn, _filter_name, _filter_params = nil) do
    Path.join(["/" | conn.path_info])
  end

  def reset_filter_path(conn, filter_name, filter_params) do
    filter_params |> Map.delete(filter_name) |> Map.delete("page") |> reset_filters_path(conn)
  end

  defp reset_filters_path(new_filter_params, conn) do
    params = Map.put(conn.params, "filter", new_filter_params)
    Path.join(["/" | conn.path_info]) <> "?" <> Plug.Conn.Query.encode(params)
  end

  def filter_present?(conn, filter_name) do
    filter = conn.params["filter"][filter_name]

    !(filter == nil || String.length(String.trim(filter)) == 0)
  end
end
