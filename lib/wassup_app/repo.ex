defmodule WassupApp.Repo do
  use Ecto.Repo,
    otp_app: :wassup_app,
    adapter: Ecto.Adapters.Postgres
end
