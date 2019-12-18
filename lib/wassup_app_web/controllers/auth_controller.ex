defmodule WassupAppWeb.AuthController do
  use WassupAppWeb, :controller
  plug Ueberauth
  plug :ensure_not_signed_in when action in [:request, :callback, :identity_callback]

  alias WassupApp.Accounts
  alias WassupApp.Accounts.User
  alias WassupApp.UeberauthInfoParser

  def request(conn, _params) do
    render(conn, "request.html")
  end

  def delete(conn, _params) do
    conn
    |> put_flash(:info, "You have been logged out!")
    |> clear_session()
    |> redirect(to: Routes.login_path(conn, :request))
  end

  def callback(%{assigns: %{ueberauth_failure: _fails}} = conn, _params) do
    conn
    |> put_flash(:error, "Failed to authenticate.")
    |> redirect(to: Routes.login_path(conn, :request))
  end

  def callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UeberauthInfoParser.parse(auth) do
      {:ok, info} ->
        authenticate_using_auth_info(conn, info)

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.login_path(conn, :request))
    end
  end

  defp authenticate_using_auth_info(conn, info) do
    case Accounts.find_or_create_user(info) do
      {:ok, %{id: id}} ->
        conn
        |> put_session(:user_id, id)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.login_path(conn, :request))
    end
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, _params) do
    case UeberauthInfoParser.parse(auth) do
      {:ok, %{email: email, password: password}} ->
        identity_authenticated(conn, Accounts.authenticate(email, password))

      {:error, error} ->
        identity_authenticated(conn, {:error, error})
    end
  end

  defp identity_authenticated(conn, {:ok, %User{} = user}) do
    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
    |> redirect(to: "/")
  end

  defp identity_authenticated(conn, {:error, error}) do
    conn
    |> put_flash(:error, error)
    |> render("request.html")
  end

  defp ensure_not_signed_in(conn, _) do
    if conn.assigns.current_user do
      conn |> redirect(to: "/") |> halt()
    else
      conn
    end
  end
end
