defmodule WassupApp.Repo.Migrations.AddVerifiedAtAndTimezoneToUsers do
  use Ecto.Migration

  def change do
    alter table(:users) do
      add :verified_at, :utc_datetime, null: true
      add :timezone, :string, null: true
    end
  end
end
