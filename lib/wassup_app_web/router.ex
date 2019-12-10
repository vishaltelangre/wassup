defmodule WassupAppWeb.Router do
  use WassupAppWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_flash
    plug :protect_from_forgery
    plug :put_secure_browser_headers
    plug WassupAppWeb.Plugs.Auth
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/", WassupAppWeb do
    pipe_through :browser

    get "/login", AuthController, :request, as: :login
    delete "/logout", AuthController, :delete, as: :logout
  end

  scope "/auth", WassupAppWeb do
    pipe_through :browser

    get "/:provider", AuthController, :request
    get "/:provider/callback", AuthController, :callback
    post "/identity/callback", AuthController, :identity_callback
  end

  scope "/", WassupAppWeb do
    pipe_through [:browser, :valid_user]

    get "/", DashboardController, :index

    resources "/notes", NoteController
  end

  # Other scopes may use custom stacks.
  # scope "/api", WassupAppWeb do
  #   pipe_through :api
  # end
  #
  # scope "/admin", WassupAppWeb.Admin, as: :admin do
  #   pipe_through :browser

  #   resources "/images",  ImageController
  #   resources "/reviews", ReviewController
  #   resources "/users",   UserController
  # end
end
