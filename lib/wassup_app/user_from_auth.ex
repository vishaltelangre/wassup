defmodule WassupApp.UeberauthInfoParser do
  @moduledoc """
  Retrieve the user information from an auth request
  """
  require Logger
  require Jason

  alias Ueberauth.Auth

  def parse(%Auth{provider: :identity} = auth) do
    case validate_pass(auth.credentials) do
      :ok ->
        {:ok,
         %{email: email_from_auth(auth), password: to_string(auth.credentials.other.password)}}

      {:error, reason} ->
        {:error, reason}
    end
  end

  def parse(%Auth{} = auth) do
    {:ok, basic_info(auth)}
  end

  defp basic_info(auth) do
    %{name: name_from_auth(auth), email: email_from_auth(auth)}
  end

  defp email_from_auth(%{info: %{email: email}}), do: email

  defp email_from_auth(auth) do
    Logger.warn(auth.provider <> " needs to find email")
    Logger.debug(Jason.encode!(auth))
    ""
  end

  defp name_from_auth(auth) do
    if auth.info.name do
      auth.info.name
    else
      name =
        [auth.info.first_name, auth.info.last_name]
        |> Enum.filter(&(&1 != nil and &1 != ""))

      if Enum.empty?(name) do
        auth.info.nickname
      else
        Enum.join(name, " ")
      end
    end
  end

  defp validate_pass(%{other: %{password: _password}}), do: :ok
  defp validate_pass(_), do: {:error, "Password required"}
end
