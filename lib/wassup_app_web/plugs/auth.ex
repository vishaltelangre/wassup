defmodule WassupAppWeb.Plugs.Auth do
  @behaviour Plug

  import Plug.Conn
  import Phoenix.Controller

  alias WassupAppWeb.Router.Helpers, as: Routes
  alias WassupApp.Auth, as: AuthContext
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

  def ensure_not_signed_in(conn, _opts) do
    if conn.assigns.current_user do
      conn |> redirect(to: "/") |> halt()
    else
      conn
    end
  end

  def ensure_password_is_set(conn, _opts) do
    current_user = conn.assigns.current_user

    if current_user && is_nil(current_user.password_hash) do
      conn |> redirect(to: Routes.account_path(conn, :edit)) |> halt()
    else
      conn
    end
  end

  def ensure_registration_enabled(conn, _opts) do
    AuthContext.ensure_registration_enabled(conn)
  end

  def ensure_account_is_verified(conn, _opts) do
    current_user = conn.assigns.current_user

    if current_user && is_nil(current_user.verified_at) do
      conn
      |> redirect(to: Routes.account_verification_pending_path(conn, :verification_pending))
      |> halt()
    else
      conn
    end
  end
end
