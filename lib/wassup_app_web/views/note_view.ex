defmodule WassupAppWeb.NoteView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [sentiments: 0]
  import WassupAppWeb.PaginateView, only: [pagination_links: 3]

  def reset_search_filter_path(conn = %Plug.Conn{}) do
    conn |> reset_search_filter_path(conn.params["filter"])
  end

  def reset_search_filter_path(conn, _filter_params = nil) do
    Path.join(["/" | conn.path_info])
  end

  def reset_search_filter_path(conn, filter_params) do
    filter_params = filter_params |> Map.delete("q") |> Map.delete("page")
    params = Map.put(conn.params, "filter", filter_params)
    Path.join(["/" | conn.path_info]) <> "?" <> Plug.Conn.Query.encode(params)
  end

  def search_filter_present?(conn) do
    search_filter = conn.params["filter"]["q"]

    !(search_filter == nil || String.length(String.trim(search_filter)) == 0)
  end
end
