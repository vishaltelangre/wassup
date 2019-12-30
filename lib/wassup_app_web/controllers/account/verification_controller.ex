defmodule WassupAppWeb.Account.VerificationController do
  use WassupAppWeb, :controller

  alias WassupApp.{Accounts, Accounts.User}
  alias WassupApp.Auth, as: AuthContext
  alias WassupApp.Token

  def verify_account(conn, %{"token" => token}) do
    with {:ok, user_id} <- Token.verify_account_verification_token(token),
         user = %User{verified_at: nil} <- Accounts.get_user(user_id) do
      mark_account_as_verified(conn, user)
    else
      _ ->
        conn
        |> put_flash(:info, "The account verification link is either expired or invalid.")
        |> redirect(to: account_verification_pending_path(conn))
    end
  end

  def verify_account(conn, _params) do
    # If there is no token in our params, tell the user they've provided
    # an invalid token or expired token
    conn
    |> put_flash(:error, "The verification link is invalid.")
    |> redirect(to: "/")
  end

  defp mark_account_as_verified(conn, user) do
    case Accounts.mark_as_verified(user) do
      {:ok, _user} ->
        after_verification(conn)

      _ ->
        conn
        |> put_flash(:info, "There was an error while verifying your account.")
        |> redirect(to: account_verification_pending_path(conn))
    end
  end

  defp after_verification(conn) do
    case conn.assigns.current_user do
      nil ->
        conn
        |> put_flash(:info, "Successfully verified your account. You can sign in now.")
        |> redirect(to: Routes.login_path(conn, :request))

      _user ->
        conn
        |> put_flash(:info, "Successfully verified your account.")
        |> redirect(to: "/")
    end
  end

  def resend_account_verification_instructions(conn, %{"account" => %{"email" => email}}) do
    do_resend_account_verification_instructions(conn, Accounts.get_user_by_email(email))
  end

  def resend_account_verification_instructions(conn, _params) do
    do_resend_account_verification_instructions(conn, conn.assigns.current_user)
  end

  defp do_resend_account_verification_instructions(conn, user) do
    conn
    |> AuthContext.send_account_verification_instructions(user)
    |> put_flash(
      :info,
      "Account verification instructions sent successfully. Please check your inbox."
    )
    |> redirect(to: account_verification_pending_path(conn))
  end

  def verification_pending(conn, _params) do
    case conn.assigns.current_user do
      %User{verified_at: nil} -> render(conn, "verification_pending.html")
      nil -> render(conn, "verification_pending.html")
      _ -> redirect(conn, to: "/")
    end
  end

  defp account_verification_pending_path(conn) do
    if conn.assigns.current_user do
      Routes.account_verification_pending_path(conn, :verification_pending)
    else
      Routes.resend_account_verification_instructions_path(conn, :verification_pending)
    end
  end
end
