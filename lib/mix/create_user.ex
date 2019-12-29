defmodule Mix.Tasks.CreateUser do
  use Mix.Task

  alias WassupApp.{Repo, Accounts}

  @impl Mix.Task
  @shortdoc "Create a user"
  @moduledoc ~S"""
  Creates a new user. It expects necessary user attributes.

  #Usage
  ```
      mix create_user --name "FULL NAME" --email EMAIL --password STRONG_PASSWORD --timezone TIMEZONE
  ```

  All following options are required.

  The `--name` option is the full name of the user.
  Use double quotes to enclose the full name.

  The `--email` option is the valid and unique email of the user.

  The `--password` option is the password for the user.

  The `--timezone` option should have a valid timezone.
  An appropriate and valid timezone value can be obtained
  using `mix timezones` task.
  All datetimes will be presented in this timezone to the user.

  ## Examples
  ```
      mix create_user --name "John Doe" --email john@example.com --password really%STRONG*password --timezone America/Chicago
  ```
  would print

  ```
      Successfully created the user!
  ```

  if successful, otherwise would print the errors.

  ```
      Error while creating the user
      : %{email: ["has already been taken"]}
  ```
  """
  def run(args) do
    Mix.Task.run("app.start")

    {parsed_options, _rest} =
      OptionParser.parse!(args,
        strict: [name: :string, email: :string, password: :string, timezone: :string]
      )

    case Accounts.create_user(parsed_options |> Enum.into(%{verified_at: Timex.now()})) do
      {:ok, _user} ->
        IO.puts("Successfully created the user!")

      {:error, %Ecto.Changeset{} = changeset} ->
        IO.inspect(changeset_errors(changeset), label: "Error while creating the user\n")
    end
  end

  defp changeset_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
