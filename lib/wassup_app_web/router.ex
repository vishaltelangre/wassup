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
    get "/graphs/timeline", GraphController, :timeline

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

  defp put_user_token(conn, _) do
    if current_user = conn.assigns[:current_user] do
      token = Phoenix.Token.sign(conn, "user socket", current_user.id)
      assign(conn, :user_token, token)
    else
      conn
    end
  end
end
