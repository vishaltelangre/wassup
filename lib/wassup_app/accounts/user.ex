defmodule WassupApp.Accounts.User do
  use WassupApp.BaseModel

  alias WassupApp.Accounts
  alias WassupApp.Accounts.User
  alias WassupApp.Notes.Note

  @email_regex ~r/^[A-Za-z0-9\._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,6}$/

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :current_password, :string, virtual: true
    field :verified_at, :utc_datetime
    field :timezone, :string
    has_many :notes, Note

    timestamps()
  end

  @doc false
  def changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation, :verified_at, :timezone])
    |> validate_required([:name, :email])
    |> maybe_require_password()
    |> maybe_require_timezone()
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> down_case_email()
    |> validate_format(:email, @email_regex)
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  def change_password_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:current_password, :password, :password_confirmation])
    |> validate_required([:current_password, :password])
    |> validate_matches_current_password()
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> put_password_hash()
  end

  defp maybe_require_password(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{verified_at: verified_at}} when not is_nil(verified_at) ->
        changeset

      %Ecto.Changeset{data: %User{password_hash: password_hash}} when not is_nil(password_hash) ->
        changeset

      _ ->
        validate_required(changeset, :password)
    end
  end

  defp maybe_require_timezone(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{verified_at: verified_at}} when not is_nil(verified_at) ->
        changeset

      _ ->
        changeset
        |> validate_required(:timezone)
        |> validate_inclusion(:timezone, Tzdata.zone_list())
    end
  end

  defp put_password_hash(changeset) do
    case changeset do
      %Ecto.Changeset{valid?: true, changes: %{password: password}} ->
        put_change(changeset, :password_hash, Argon2.hash_pwd_salt(password))

      _ ->
        changeset
    end
  end

  defp down_case_email(changeset) do
    case get_field(changeset, :email) do
      nil ->
        changeset

      email ->
        put_change(changeset, :email, String.downcase(email))
    end
  end

  defp validate_matches_current_password(%Ecto.Changeset{errors: errors} = changeset) do
    if Keyword.has_key?(errors, :current_password) do
      changeset
    else
      current_password = to_string(get_field(changeset, :current_password))

      case Accounts.get_user(get_field(changeset, :id)) do
        %User{password_hash: password_hash} ->
          if Argon2.verify_pass(current_password, password_hash) do
            changeset
          else
            add_error(changeset, :current_password, "does not match with current password")
          end

        _ ->
          add_error(changeset, :current_password, "invalid")
      end
    end
  end
end
