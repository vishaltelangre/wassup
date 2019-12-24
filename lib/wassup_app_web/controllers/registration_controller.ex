defmodule WassupAppWeb.RegistrationController do
  use WassupAppWeb, :controller

  alias WassupApp.{Accounts, Accounts.User}

  def new(conn, _params) do
    changeset = Accounts.change_user(%User{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"user" => user_params}) do
    case Accounts.create_user(user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Signed up successfully.")
        |> redirect(to: Routes.login_path(conn, :request))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end
end
