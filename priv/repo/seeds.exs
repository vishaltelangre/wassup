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

Notes.create_note_for_user(user.id, %{
  body: "John's first note",
  favorite: true,
  sentiment: :happy
})

Notes.create_note_for_user(user.id, %{
  body: "John's second note",
  sentiment: :neutral
})

{:ok, user} =
  Accounts.find_or_create_user(%{
    name: "Jane Doe",
    email: "jane@example.com",
    password: "test1234"
  })

Notes.create_note_for_user(user.id, %{
  body: "I am bored now",
  sentiment: :bored
})
