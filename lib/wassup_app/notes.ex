defmodule WassupApp.Notes do
  @moduledoc """
  The Notes context.
  """

  import Ecto.Query, warn: false
  alias WassupApp.Repo

  alias WassupApp.Notes.{Note, FilteredNotePaginator}
  alias WassupApp.Accounts.User

  @doc """
  Returns the list of notes for a user.

  ## Examples

      iex> list_notes_for_user()
      [%Note{}, ...]

  """
  def list_notes_for_user(%User{} = user, options \\ []) do
    default_options = [order_by: [desc: :submitted_at]]
    options = Keyword.merge(default_options, options)

    query =
      Note
      |> where(user_id: ^user.id)
      |> maybe_between_period(options[:period])
      |> maybe_search_condition(options[:q])
      |> order_by(^options[:order_by])
      |> maybe_limit(options[:limit])

    Repo.all(query) |> Enum.map(&Note.transform_fields(&1, user.timezone))
  end

  defp maybe_between_period(query, %{from: from, to: to}) do
    query |> where([n], n.submitted_at >= ^from and n.submitted_at <= ^to)
  end

  defp maybe_between_period(query, _period), do: query

  defp maybe_search_condition(query, ""), do: query
  defp maybe_search_condition(query, nil), do: query

  defp maybe_search_condition(query, q) do
    query |> where([n], ilike(n.body, ^"%#{q}%"))
  end

  defp maybe_limit(query, _limit = nil), do: query

  defp maybe_limit(query, limit) do
    query |> limit(^limit)
  end

  @doc """
  Returns the filtered and paginated notes for a user.

  ## Examples

      iex> paginate_notes_for_user(%User{}, %{"q" => "house", "per_page" => 10, "page" => 2})
      %{data: [%Note{}, ...], paginate: %{current_page: 2, next_page: 3, per_page: 10, prev_page: 1, total_count: 50, total_pages: 5}}

  """
  def paginate_notes_for_user(%User{} = user, criteria \\ %{}) do
    Note
    |> where(user_id: ^user.id)
    |> FilteredNotePaginator.paginate(criteria |> Map.put("timezone", user.timezone))
    |> transform_paginated_note_fields(user.timezone)
  end

  defp transform_paginated_note_fields(%{data: data} = paginate_result, timezone) do
    paginate_result
    |> Map.put(:data, data |> Enum.map(&Note.transform_fields(&1, timezone)))
  end

  @doc """
  Gets a single note.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note!(123)
      %Note{}

      iex> get_note!(456)
      ** (Ecto.NoResultsError)

  """
  def get_note!(id) do
    Note
    |> Repo.get!(id)
    |> Note.transform_fields()
  end

  @doc """
  Gets a single note for a user.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note_for_user!(%User{}, 123)
      %Note{}

      iex> get_note_for_user!(%User{}, 456)
      ** (Ecto.NoResultsError)

  """
  def get_note_for_user!(user, id) do
    Note
    |> where(user_id: ^user.id)
    |> Repo.get!(id)
    |> Note.transform_fields(user.timezone)
  end

  @doc """
  Creates a note for a user.

  ## Examples

      iex> create_note_for_user(user_id, %{field: value})
      {:ok, %Note{}}

      iex> create_note_for_user(user_id, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_note_for_user(user_id, attrs \\ %{}) do
    %Note{}
    |> Note.changeset(attrs)
    |> Ecto.Changeset.put_change(:user_id, user_id)
    |> Repo.insert()
  end

  @doc """
  Updates a note.

  ## Examples

      iex> update_note_for_user(user, note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note_for_user(user, note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note_for_user(%User{} = user, %Note{} = note, attrs) do
    case note |> Note.changeset(attrs) |> Repo.update() do
      {:ok, note} -> {:ok, Note.transform_fields(note, user.timezone)}
      {:error, changeset} -> {:error, changeset}
    end
  end

  @doc """
  Deletes a Note.

  ## Examples

      iex> delete_note(note)
      {:ok, %Note{}}

      iex> delete_note(note)
      {:error, %Ecto.Changeset{}}

  """
  def delete_note(%Note{} = note) do
    Repo.delete(note)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking note changes.

  ## Examples

      iex> change_note(note)
      %Ecto.Changeset{source: %Note{}}

  """
  def change_note(note, attrs \\ %{}) do
    Note.changeset(note, attrs)
  end
end
