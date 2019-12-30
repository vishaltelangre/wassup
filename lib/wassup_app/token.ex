defmodule WassupApp.Token do
  alias WassupAppWeb.Endpoint
  alias WassupApp.Accounts.User

  @account_verification_token_salt "account verification salt"

  def generate_account_verification_token(%User{id: user_id}) do
    Phoenix.Token.sign(Endpoint, @account_verification_token_salt, user_id)
  end

  def verify_account_verification_token(token) do
    # tokens that are older than a day should be invalid
    max_age = 24 * 60 * 60
    Phoenix.Token.verify(Endpoint, @account_verification_token_salt, token, max_age: max_age)
  end
end
