defmodule WassupApp.Token do
  alias WassupAppWeb.Endpoint
  alias WassupApp.Accounts.User

  def generate_account_verification_token(%User{id: user_id}) do
    Phoenix.Token.sign(Endpoint, token_salt(), user_id)
  end

  def verify_account_verification_token(token) do
    # tokens that are older than a day should be invalid
    verify_token(token, 24 * 60 * 60)
  end

  def generate_password_reset_token(%User{id: user_id}) do
    Phoenix.Token.sign(Endpoint, token_salt(), user_id)
  end

  def verify_password_reset_token(token) do
    # tokens that are older than a day should be invalid
    verify_token(token, 24 * 60 * 60)
  end

  defp verify_token(token, max_age) do
    Phoenix.Token.verify(Endpoint, token_salt(), token, max_age: max_age)
  end

  defp token_salt, do: System.get_env("SECRET_KEY_BASE") || "secret salt"
end
