defmodule WassupAppWeb.AuthController do
  use WassupAppWeb, :controller
  plug Ueberauth

  alias WassupApp.Auth
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
        conn
        |> ensure_user_already_exists_or_registration_enabled(info)
        |> authenticate_using_auth_info(Map.put(info, :verified_at, Timex.now()))

      {:error, reason} ->
        conn
        |> put_flash(:error, reason)
        |> redirect(to: Routes.login_path(conn, :request))
    end
  end

  defp ensure_user_already_exists_or_registration_enabled(conn, info) do
    case Accounts.get_user_by_email(info.email) do
      %User{} -> conn
      nil -> Auth.ensure_registration_enabled(conn)
    end
  end

  defp authenticate_using_auth_info(conn = %{halted: true}, _info), do: conn

  defp authenticate_using_auth_info(conn, info) do
    case Accounts.find_or_create_user(info) do
      {:ok, %User{id: id, password_hash: _password_hash}} ->
        conn
        |> put_session(:user_id, id)
        |> configure_session(renew: true)
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{errors: [password: {_, _}], valid?: false} = _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.login_path(conn, :request))

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "Authentication failed")

        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.login_path(conn, :request))
    end
  end

  def identity_callback(%{assigns: %{ueberauth_auth: auth}} = conn, params) do
    case UeberauthInfoParser.parse(auth) do
      {:ok, %{email: email, password: password}} ->
        identity_authenticated(conn, Accounts.authenticate(email, password), params)

      {:error, error} ->
        identity_authenticated(conn, {:error, error}, params)
    end
  end

  defp identity_authenticated(conn, {:ok, %User{} = user}, params) do
    redirect_to = params["redirect_to"] |> to_string() |> String.trim()
    redirect_to = if String.length(redirect_to) > 0, do: redirect_to, else: "/"

    conn
    |> put_session(:user_id, user.id)
    |> configure_session(renew: true)
    |> redirect(to: redirect_to)
  end

  defp identity_authenticated(conn, {:error, error}, _params) do
    conn
    |> put_flash(:error, error)
    |> render("request.html")
  end
end
