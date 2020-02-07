# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config
alias WassupApp.Utils

config :elixir, :time_zone_database, Tzdata.TimeZoneDatabase

config :wassup_app,
  ecto_repos: [WassupApp.Repo]

# Configures the endpoint
config :wassup_app, WassupAppWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "jj4AvO5bojcIvY4ttxNobXA6PDEQbSpYzL0nE0M8WCqqpDPegU8rsIAvvnGM9s44",
  render_errors: [view: WassupAppWeb.ErrorView, accepts: ~w(html json)],
  pubsub: [name: WassupApp.PubSub, adapter: Phoenix.PubSub.PG2],
  live_view: [
    signing_salt: "l52cziB8xK3W/0+Zw6ZSxzJ9RfEkwn4t"
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :ueberauth, Ueberauth,
  providers: [
    identity:
      {Ueberauth.Strategy.Identity,
       [callback_methods: ["POST"], uid_field: :email, nickname_field: :email]},
    google: {Ueberauth.Strategy.Google, [default_scope: "email profile"]}
  ]

config :ueberauth, Ueberauth.Strategy.Google.OAuth,
  client_id: {System, :get_env, ["GOOGLE_CLIENT_ID"]},
  client_secret: {System, :get_env, ["GOOGLE_CLIENT_SECRET"]},
  redirect_uri: {System, :get_env, ["GOOGLE_REDIRECT_URI"]}

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"

if System.get_env("DEMO") == "true" do
  # Use LocalAdapter for sending emails and previewing them in a demo instance
  config :wassup_app, WassupAppWeb.Mailer, adapter: Bamboo.LocalAdapter
end
