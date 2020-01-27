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
        render(conn, "edit.html", changeset: changeset)
    end
  end

  def change_password(conn, _params) do
    changeset = Accounts.change_user(conn.assigns.current_user)
    render(conn, "change_password.html", changeset: changeset)
  end

  def update_password(conn, %{"user" => user_params}) do
    case Accounts.update_password(conn.assigns.current_user, user_params) do
      {:ok, _user} ->
        conn
        |> put_flash(:info, "Password changed successfully.")
        |> redirect(to: Routes.account_change_password_path(conn, :change_password))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "change_password.html", changeset: changeset)
    end
  end
end
