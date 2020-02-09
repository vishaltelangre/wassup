defmodule WassupApp.MixProject do
  use Mix.Project

  def project do
    [
      app: :wassup_app,
      version: "0.1.0",
      elixir: "~> 1.9",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix, :gettext] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {WassupApp.Application, []},
      extra_applications: app_list(Mix.env())
    ]
  end

  defp app_list(:dev), do: [:dotenv | app_list()]
  defp app_list(_), do: app_list()

  defp app_list(),
    do: [
      :logger,
      :ueberauth,
      :ueberauth_identity,
      :ueberauth_google,
      :timex,
      :bamboo,
      :bamboo_smtp
    ]

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.4.10"},
      {:phoenix_pubsub, "~> 1.1"},
      {:phoenix_ecto, "~> 4.0"},
      {:ecto_sql, "~> 3.1"},
      {:ecto_enum, "~> 1.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 2.11"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      # Ensure that it contains this fix - https://github.com/phoenixframework/phoenix_live_view/commit/b81a12504013d7c8b56a50891ede809dbb8be4af
      {:phoenix_live_view,
       github: "phoenixframework/phoenix_live_view",
       ref: "b81a12504013d7c8b56a50891ede809dbb8be4af"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:ueberauth, "~> 0.6"},
      {:ueberauth_identity, "~> 0.2"},
      {:ueberauth_google, "~> 0.8"},
      {:argon2_elixir, "~> 2.0"},
      {:dotenv, "~> 3.0.0"},
      {:timex, "~> 3.5"},
      {:bamboo, "~> 1.3"},
      {:bamboo_smtp, "~> 2.1.0"},
      {:faker, "~> 0.13"},
      {:csv, "~> 2.3"},
      {:briefly, github: "CargoSense/briefly", ref: "2526e96"},
      {:veritaserum, "~> 0.2.1"},
      {:quantum, "~> 2.3"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to create, migrate and run the seeds file at once:
  #
  #     $ mix ecto.setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate", "test"]
    ]
  end
end
