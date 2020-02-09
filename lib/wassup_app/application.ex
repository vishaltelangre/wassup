defmodule WassupApp.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    import Supervisor.Spec, warn: false

    # List all child processes to be supervised
    children = [
      # Start the Ecto repository
      WassupApp.Repo,
      # Start the endpoint when the application starts
      WassupAppWeb.Endpoint,
      # Starts a worker by calling: WassupApp.Worker.start_link(arg)
      # {WassupApp.Worker, arg},
      # Start the scheduler
      WassupAppWeb.Scheduler
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: WassupApp.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  def config_change(changed, _new, removed) do
    WassupAppWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
