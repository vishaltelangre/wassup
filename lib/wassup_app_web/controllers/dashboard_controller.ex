defmodule WassupAppWeb.DashboardController do
  use WassupAppWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
