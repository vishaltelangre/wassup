defmodule WassupApp.Accounts.User do
  use WassupApp.BaseModel

  alias WassupApp.Accounts.User
  alias WassupApp.Notes.Note

  schema "users" do
    field :name, :string
    field :email, :string
    field :password_hash, :string
    field :password, :string, virtual: true
    field :password_confirmation, :string, virtual: true
    field :verified_at, :utc_datetime
    field :timezone, :string
    has_many :notes, Note

    timestamps()
  end

  @doc false
  def registration_changeset(%User{} = user, attrs) do
    user
    |> cast(attrs, [:name, :email, :password, :password_confirmation, :verified_at, :timezone])
    |> validate_required([:name, :email])
    |> maybe_require_password()
    |> maybe_require_timezone()
    |> validate_length(:password, min: 6)
    |> validate_confirmation(:password)
    |> down_case_email()
    |> unique_constraint(:email)
    |> put_password_hash()
  end

  defp maybe_require_password(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{verified_at: _}} ->
        changeset

      _ ->
        validate_required(changeset, :password)
    end
  end

  defp maybe_require_timezone(changeset) do
    case changeset do
      %Ecto.Changeset{changes: %{verified_at: _}} ->
        changeset

      _ ->
        validate_required(changeset, :timezone)
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
end
