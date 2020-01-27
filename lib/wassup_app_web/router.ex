defmodule WassupAppWeb.Router do
  use WassupAppWeb, :router
  alias WassupApp.Utils

  # To preview sent emails
  if Mix.env() == :dev || Utils.demo_instance?() do
    forward "/sent_emails", Bamboo.SentEmailViewerPlug
  end

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug Phoenix.LiveView.Flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WassupAppWeb.Plugs.Auth
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser]

    # Account verification
    get "/verify_account", Account.VerificationController, :verify_account, as: :verify_account

    post "/resend_account_verification_instructions",
         Account.VerificationController,
         :resend_account_verification_instructions,
         as: :account_verification
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :ensure_not_signed_in]

    # Login
    get "/login", AuthController, :request, as: :login
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/identity/callback", AuthController, :identity_callback

    # Resend account verification instructions
    get "/resend_account_verification_instructions",
        Account.VerificationController,
        :verification_pending,
        as: :resend_account_verification_instructions
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :ensure_not_signed_in, :ensure_registration_enabled]

    # Registration
    get "/register", RegistrationController, :new
    post "/register", RegistrationController, :create
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :valid_user]

    # Logout
    delete "/logout", AuthController, :delete, as: :logout

    # Account Management
    resources "/account", AccountController, singleton: true, only: [:edit, :update] do
      get "/change_password", AccountController, :change_password, as: :change_password
      put "/update_password", AccountController, :update_password, as: :update_password
    end

    get "/account/verification_pending",
        Account.VerificationController,
        :verification_pending,
        as: :account_verification_pending
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :valid_user, :ensure_password_is_set, :ensure_account_is_verified]

    # Dashboard
    live "/", DashboardLive

    # Graphs
    live "/graphs/timeline", GraphLive.Timeline

    # Notes
    live "/notes", NoteLive.Index
  end

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
