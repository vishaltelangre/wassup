defmodule WassupAppWeb.PasswordResetController do
  use WassupAppWeb, :controller

  alias WassupApp.{Accounts, Accounts.User}
  alias WassupApp.Auth, as: AuthContext
  alias WassupApp.Token

  def new(conn, _params) do
    render(conn, "new.html")
  end

  def create(conn, %{"password_reset" => %{"email" => email}}) do
    conn
    |> AuthContext.send_password_reset_instructions(Accounts.get_user_by_email(email))
    |> put_flash(
      :info,
      "Password reset instructions sent successfully. Please check your inbox."
    )
    |> redirect(to: Routes.password_reset_path(conn, :new))
  end

  def change_password(conn, %{"token" => token}) do
    with {:ok, user_id} <- Token.verify_password_reset_token(token),
         user = %User{email: _email} <- Accounts.get_user(user_id) do
      render(conn, "change_password.html", changeset: Accounts.change_user(user), token: token)
    else
      _ ->
        conn
        |> put_flash(:warn, "The password reset link is either expired or invalid.")
        |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end

  def change_password(conn, _params) do
    # If there is no token in our params, tell the user they've provided
    # an invalid token or expired token
    conn
    |> put_flash(:error, "The password reset link is invalid.")
    |> redirect(to: "/")
  end

  def update_password(conn, %{"user" => %{"token" => token} = user_params}) do
    with {:ok, user_id} <- Token.verify_password_reset_token(token),
         user = %User{} <- Accounts.get_user(user_id) do
      permitted_user_params = user_params |> Map.take(["password", "password_confirmation"])

      case Accounts.update_user(user, permitted_user_params) do
        {:ok, _user} ->
          conn
          |> put_flash(:info, "Password changed successfully.")
          |> redirect(to: Routes.login_path(conn, :request))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "change_password.html", changeset: changeset, token: token)
      end
    else
      _ ->
        conn
        |> put_flash(:warn, "The password reset link is either expired or invalid.")
        |> redirect(to: Routes.password_reset_path(conn, :new))
    end
  end
end
