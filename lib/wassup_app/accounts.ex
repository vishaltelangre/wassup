defmodule WassupApp.Accounts do
  @moduledoc """
  The Accounts context.
  """

  import Ecto.Query, warn: false

  alias WassupApp.Repo
  alias WassupApp.Accounts.User

  @doc """
  Gets a single user.

  Raises `Ecto.NoResultsError` if the User does not exist.

  ## Examples

      iex> get_user!(123)
      %User{}

      iex> get_user!(456)
      ** (Ecto.NoResultsError)

  """
  def get_user!(id), do: Repo.get!(User, id)

  @doc """
  Gets a single user.

  Returns `nil` if the User does not exist.

  ## Examples

      iex> get_user(123)
      %User{}

      iex> get_user(456)
      nil

  """
  def get_user(id), do: Repo.get(User, id)

  @doc """
  Gets a user by email.

  Returns `nil` if no matching User is found.

  ## Examples

      iex> get_user_by_email("sam@example.com")
      %User{}

      iex> get_user_by_email("absent-user@example.com")
      nil

  """
  def get_user_by_email(email) do
    email = email |> to_string |> String.downcase()

    Repo.get_by(User, email: email)
  end

  @doc """
  Creates a user.

  ## Examples

      iex> create_user(%{field: value})
      {:ok, %User{}}

      iex> create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_user(attrs \\ %{}) do
    %User{}
    |> User.registration_changeset(attrs_with_random_password_when_missing(attrs))
    |> Repo.insert()
  end

  defp attrs_with_random_password_when_missing(attrs) do
    random_password =
      :crypto.strong_rand_bytes(16)
      |> Base.url_encode64()
      |> binary_part(0, 16)

    attrs
    |> Map.put_new(:password, random_password)
  end

  @doc """
    Find user by the given email or create a user with all the specified attrs.

  ## Examples

      iex> find_or_create_user(%{field: value})
      {:ok, %User{}}

      iex> find_or_create_user(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def find_or_create_user(attrs) do
    case get_user_by_email(attrs.email) do
      %User{} = user -> {:ok, user}
      nil -> create_user(attrs)
    end
  end

  @doc """
  Updates a user.

  ## Examples

      iex> update_user(user, %{field: new_value})
      {:ok, %User{}}

      iex> update_user(user, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_user(%User{} = user, attrs) do
    # TODO

    # user
    # |> User.changeset(attrs)
    # |> Repo.update()
  end

  @doc """
  Deletes a user.

  ## Examples

      iex> delete_user(user)
      {:ok, %User{}}

      iex> delete_user(user)
      {:error, %Ecto.Changeset{}}

  """
  def delete_user(%User{} = user) do
    Repo.delete(user)
  end

  @doc """
  Authenticates a user using email and password.

  ## Examples

      iex> authenticate("sam@example.com", "password")
      {:ok, %User{}}

      iex> authenticate(("sam@example.com", "wrongpassword")
      {:error, "Invalid email or password"}

  """
  def authenticate(email, password) do
    get_user_by_email(email)
    |> do_authenticate(password)
  end

  defp do_authenticate(nil, _auth), do: {:error, "Invalid email or password"}

  defp do_authenticate(user, password) do
    if Argon2.verify_pass(password, user.password_hash) do
      {:ok, user}
    else
      {:error, "Invalid email or password"}
    end
  end
end
