# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     WassupApp.Repo.insert!(%WassupApp.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

alias WassupApp.Accounts
alias WassupApp.Accounts.User
alias WassupApp.Notes
alias WassupApp.Notes.Note
alias WassupApp.Repo
alias WassupApp.Utils

if (Mix.env() == :prod && Utils.demo_instance?()) || Mix.env() != :prod do
  Repo.delete_all(User)

  {:ok, user} =
    Accounts.find_or_create_user(%{
      name: "John Doe",
      email: "john@example.com",
      timezone: Tzdata.zone_list() |> Enum.random(),
      verified_at: Timex.now(),
      password: "test1234",
      remind_to_note: "when_missed_in_last_07_days"
    })

  Enum.map(1..200, fn n ->
    Notes.create_note_for_user(user.id, %{
      body: Faker.Lorem.sentence(Enum.random(10..20)),
      favorite: Enum.random(0..1) == 0,
      sentiment: Enum.random(Note.sentiment_details() |> Map.keys()),
      submitted_at: DateTime.utc_now() |> DateTime.add(-60 * 60 * n)
    })
  end)
end
