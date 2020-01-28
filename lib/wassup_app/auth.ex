defmodule WassupApp.Auth do
  import Plug.Conn
  import Phoenix.Controller

  alias WassupApp.Accounts.User
  alias WassupApp.Token
  alias WassupApp.Utils
  alias WassupAppWeb.Mailer
  alias WassupAppWeb.Mailer.Email
  alias WassupAppWeb.Router.Helpers, as: Routes
  alias WassupAppWeb.Endpoint

  def registration_disabled?() do
    Utils.get_env({:system, "REGISTRATION_DISABLED"}) == "true"
  end

  def ensure_registration_enabled(conn) do
    if registration_disabled?() do
      conn
      |> put_flash(
        :info,
        "Sorry! Registration is not enabled at this moment. Please contact the administrator."
      )
      |> redirect(to: Routes.login_path(conn, :request))
      |> halt()
    else
      conn
    end
  end

  # Send account verification link only when `verified_at` is `nil`
  def send_account_verification_instructions(user),
    do: send_account_verification_instructions(Endpoint, user)

  def send_account_verification_instructions(conn, nil), do: conn

  def send_account_verification_instructions(
        conn,
        %User{id: _id, email: _email, verified_at: nil} = user
      ) do
    token = Token.generate_account_verification_token(user)
    verification_url = Routes.verify_account_url(conn, :verify_account, token: token)

    Email.welcome_email(user, verification_url) |> Mailer.deliver_later()
    conn
  end

  def send_account_verification_instructions(conn, _user), do: conn

  # Send password reset link
  def send_password_reset_instructions(conn, nil = _user), do: conn

  def send_password_reset_instructions(conn, user) do
    token = Token.generate_password_reset_token(user)
    change_password_link = Routes.change_password_url(conn, :change_password, token: token)

    Email.reset_password_email(user, change_password_link) |> Mailer.deliver_later()

    conn
  end
end
