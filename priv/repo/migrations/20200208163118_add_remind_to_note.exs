defmodule WassupApp.Repo.Migrations.AddRemindToNote do
  use Ecto.Migration

  alias WassupApp.Accounts.User.RemindToNoteEnum

  def change do
    alter table(:users) do
      add(:remind_to_note, RemindToNoteEnum.type(),
        default: "when_missed_in_last_07_days",
        null: false
      )
    end
  end
end
