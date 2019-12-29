defmodule Mix.Tasks.Timezones do
  use Mix.Task

  @impl Mix.Task
  @shortdoc "List all timezones"
  def run(_) do
    Application.ensure_all_started(:timex)

    IO.puts(Tzdata.zone_list() |> Enum.join("\n"))
  end
end
