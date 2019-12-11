defmodule WassupApp.Repo.Migrations.CreateNotes do
  use Ecto.Migration

  def change do
    create table(:notes, primary_key: false) do
      add :id, :uuid, primary_key: true
      add :body, :string
      add :favorite, :boolean, default: false, null: false
      add :sentiment, SentimentEnum.type(), null: false
      add :submitted_at, :naive_datetime, default: fragment("clock_timestamp()")
      add :user_id, references(:users, type: :uuid, on_delete: :delete_all), null: false

      timestamps()
    end

    create index(:notes, [:user_id])
    create index(:notes, [:user_id, :favorite])
    create index(:notes, [:user_id, :sentiment])
  end
end
