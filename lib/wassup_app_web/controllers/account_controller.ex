defmodule WassupAppWeb.AccountController do
  use WassupAppWeb, :controller

  alias WassupApp.Accounts

  def edit(conn, _params) do
    changeset = Accounts.change_user(conn.assigns.current_user)
    render(conn, "edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => %{"email" => _email}}) do
    changeset = Accounts.change_user(conn.assigns.current_user)

    conn
    |> put_flash(:error, "Changing email is not supported while updating account")
    |> render("edit.html", changeset: changeset)
  end

  def update(conn, %{"user" => user_params}) do
    case Accounts.update_user(conn.assigns.current_user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Account updated successfully.")
        |> redirect(to: "/")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset, label: "Error while updating account")
        render(conn, "edit.html", changeset: changeset)
    end
  end
end
