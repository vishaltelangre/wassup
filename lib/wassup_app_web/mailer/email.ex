defmodule WassupAppWeb.Mailer.Email do
  import Bamboo.Email

  use Bamboo.Phoenix, view: WassupAppWeb.EmailView

  alias WassupApp.Accounts.User
  alias WassupApp.Utils
  alias WassupAppWeb.Endpoint
  alias WassupAppWeb.Router.Helpers, as: Routes

  def welcome_email(%User{email: email} = user, account_verification_link) do
    base_email()
    |> to(email)
    |> subject("Welcome to #{Utils.app_name()}")
    |> assign(:user, user)
    |> assign(:account_verification_link, account_verification_link)
    |> render(:welcome)
  end

  def reset_password_email(%User{email: email} = user, change_password_link) do
    base_email()
    |> to(email)
    |> subject("Resetting your #{Utils.app_name()} password")
    |> assign(:user, user)
    |> assign(:change_password_link, change_password_link)
    |> render(:reset_password)
  end

  def remind_to_note_email(%User{email: email} = user, help_text) do
    base_email()
    |> to(email)
    |> subject("Reminder to add a note in #{Utils.app_name()}")
    |> assign(:user, user)
    |> assign(:help_text, help_text)
    |> assign(:preferences_url, Routes.account_url(Endpoint, :edit))
    |> render(:remind_to_note)
  end

  defp base_email do
    new_email()
    |> from(Utils.mail_sender_email())
    |> put_layout({WassupAppWeb.LayoutView, :email})
    |> assign(:app_name, Utils.app_name())
    |> assign(:app_url, Utils.app_url())
  end
end
