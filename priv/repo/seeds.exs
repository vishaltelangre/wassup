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
alias WassupApp.Notes

{:ok, user} =
  Accounts.find_or_create_user(%{
    name: "John Doe",
    email: "john@example.com",
    password: "test1234"
  })

Enum.map(1..100, fn n ->
  Notes.create_note_for_user(user.id, %{
    body: "John's #{n} note",
    favorite: Enum.random(0..1) == 0,
    sentiment: Enum.random(WassupApp.Notes.Note.sentiment_details() |> Map.keys()),
    submitted_at: DateTime.utc_now() |> DateTime.add(-60 * 60 * 24 * n)
  })
end)

{:ok, user} =
  Accounts.find_or_create_user(%{
    name: "Jane Doe",
    email: "jane@example.com",
    password: "test1234"
  })

Notes.create_note_for_user(user.id, %{
  body: "I am neutral now",
  sentiment: :neutral,
  submitted_at: DateTime.utc_now() |> DateTime.add(-60 * 60 * 24 * 3)
})

Notes.create_note_for_user(user.id, %{
  body: "I am bored now",
  sentiment: :sad,
  submitted_at: DateTime.utc_now() |> DateTime.add(-3)
})

Notes.create_note_for_user(user.id, %{
  body: "I am happy now",
  sentiment: :happy,
  submitted_at: DateTime.utc_now() |> DateTime.add(-120)
})

Notes.create_note_for_user(user.id, %{
  body: "I am happy now",
  sentiment: :happy,
  submitted_at: DateTime.utc_now() |> DateTime.add(-60 * 60 * 24 * 1)
})

Notes.create_note_for_user(user.id, %{
  body: "I am happy now",
  sentiment: :happy,
  submitted_at: DateTime.utc_now() |> DateTime.add(-60 * 60)
})
