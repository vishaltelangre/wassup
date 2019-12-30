defmodule WassupAppWeb.Mailer.Email do
  import Bamboo.Email

  use Bamboo.Phoenix, view: WassupAppWeb.EmailView

  alias WassupApp.Accounts.User
  alias WassupApp.Utils

  def welcome_email(%User{email: email} = user, account_verification_link) do
    base_email()
    |> to(email)
    |> subject("Welcome to #{Utils.app_name()}")
    |> assign(:app_name, Utils.app_name())
    |> assign(:user, user)
    |> assign(:account_verification_link, account_verification_link)
    |> render(:welcome)
  end

  defp base_email do
    new_email()
    |> from(Utils.mail_sender_email())
    |> put_layout({WassupAppWeb.LayoutView, :email})
  end
end
