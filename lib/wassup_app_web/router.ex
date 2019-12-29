defmodule WassupAppWeb.Router do
  use WassupAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html", "json"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WassupAppWeb.Plugs.Auth
    plug :put_user_token
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :ensure_not_signed_in]

    # Login
    get "/login", AuthController, :request, as: :login
    get "/auth/:provider", AuthController, :request
    get "/auth/:provider/callback", AuthController, :callback
    post "/auth/identity/callback", AuthController, :identity_callback
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
    resources "/account", AccountController, singleton: true, only: [:edit, :update]
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :valid_user, :ensure_password_is_set]

    # Dashboard
    get "/", DashboardController, :index

    # Graphs
    get "/graphs/timeline", GraphController, :timeline

    # Notes
    resources "/notes", NoteController, except: [:new, :show, :edit] do
      put "/toggle_favorite", NoteController, :toggle_favorite, as: :toggle_favorite
    end
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
