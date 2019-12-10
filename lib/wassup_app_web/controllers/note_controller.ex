defmodule WassupAppWeb.NoteController do
  use WassupAppWeb, :controller

  def index(conn, _params) do
    render(conn, :index)
  end
end
