defmodule WassupAppWeb.Plugs.Auth do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller

  alias WassupAppWeb.Router.Helpers, as: Routes
  alias WassupApp.Accounts

  def init(opts), do: opts

  def call(conn, _opts) do
    user_id = get_session(conn, :user_id)

    cond do
      user = user_id && Accounts.get_user(user_id) ->
        assign(conn, :current_user, user)

      true ->
        assign(conn, :current_user, nil)
    end
  end

  def valid_user(conn, _opts) do
    cond do
      conn.assigns.current_user ->
        conn

      true ->
        conn
        |> put_flash(:error, "You must be logged in to access that page")
        |> redirect(to: Routes.login_path(conn, :request))
        |> halt()
    end
  end
end
