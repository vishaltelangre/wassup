defmodule WassupAppWeb.RegistrationController do
  use WassupAppWeb, :controller

  alias WassupApp.{Accounts, Accounts.User}
  alias WassupApp.Auth, as: AuthContext

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    user_params = user_params |> Map.put("remind_to_note", "when_missed_in_last_07_days")

    case Accounts.create_user(user_params) do
      {:ok, user} ->
        conn
        |> AuthContext.send_account_verification_instructions(user)
        |> put_flash(
          :info,
          "You are signed up successfully. We have sent you an email with the instructions to verify your account."
        )
        |> redirect(to: Routes.login_path(conn, :request))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
