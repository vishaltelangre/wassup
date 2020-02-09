defmodule WassupApp.Jobs.NoteReminderJob do
  alias WassupApp.Accounts.User
  alias WassupApp.Notes.Note
  alias WassupApp.Repo
  alias WassupAppWeb.Mailer
  alias WassupAppWeb.Mailer.Email

  import Ecto.Query, warn: false

  # At 9 PM in local timezone
  @run_at %{hour: 21, minute: 0}

  def run() do
    Repo.transaction(fn ->
      User
      |> where([u], not is_nil(u.verified_at))
      |> where([u], u.timezone in ^timezones_with_matching_local_time())
      |> where([u], u.remind_to_note != "never")
      |> Repo.stream()
      |> Enum.each(&remind_user_to_note/1)
    end)
  end

  defp remind_user_to_note(user) do
    if remind_user_to_note?(user) do
      help_text = remind_to_note_email_contents(user)

      user
      |> Email.remind_to_note_email(help_text)
      |> Mailer.deliver_later()
    end
  end

  defp remind_user_to_note?(user) do
    case last_note_by_user(user) do
      nil ->
        true

      %{submitted_at: submitted_at} ->
        %{from: start, to: ending} = remind_to_note_interval(user)
        not Timex.between?(Timex.to_datetime(submitted_at), start, ending)
    end
  end

  defp remind_to_note_interval(user) do
    now = Timex.now(user.timezone)

    case user.remind_to_note do
      :when_missed_in_24_hours -> %{from: Timex.shift(now, hours: -24), to: now}
      :when_missed_in_last_07_days -> %{from: Timex.shift(now, days: -7), to: now}
      :when_missed_in_last_15_days -> %{from: Timex.shift(now, days: -15), to: now}
      :when_missed_in_last_30_days -> %{from: Timex.shift(now, days: -30), to: now}
    end
  end

  defp remind_to_note_email_contents(user) do
    case user.remind_to_note do
      :when_missed_in_24_hours -> "in last 24 hours"
      :when_missed_in_last_07_days -> "in last 7 days"
      :when_missed_in_last_15_days -> "in last 15 days"
      :when_missed_in_last_30_days -> "in last 30 days"
    end
  end

  defp last_note_by_user(user),
    do: Note |> where(user_id: ^user.id) |> last(:submitted_at) |> Repo.one()

  defp timezones_with_matching_local_time() do
    Tzdata.zone_list()
    |> Enum.filter(fn zone ->
      local_time = Timex.now(zone)
      # Does this local time sits between 21:00 and 21:15?
      local_time.hour == @run_at.hour && local_time.minute < @run_at.minute + 15
    end)
  end
end
