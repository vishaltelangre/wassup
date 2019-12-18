defmodule WassupApp.Notes do
  @moduledoc """
  The Notes context.
  """

  import Ecto.Query, warn: false
  alias WassupApp.Repo

  alias WassupApp.Notes.{Note, FilteredNotePaginator}

  @doc """
  Returns the list of notes for a user.

  ## Examples

      iex> list_notes_for_user()
      [%Note{}, ...]

  """
  def list_notes_for_user(user_id, options \\ []) do
    default_options = [order_by: [desc: :submitted_at], limit: -1]
    options = Keyword.merge(default_options, options)

    query =
      Note
      |> where(user_id: ^user_id)
      |> order_by(^options[:order_by])

    query =
      if options[:limit] == -1 do
        query
      else
        query |> limit(^options[:limit])
      end

    Repo.all(query)
  end

  @doc """
  Returns the filtered and paginated notes for a user.

  ## Examples

      iex> paginate_notes_for_user("1234", %{"q" => "house", "per_page" => 10, "page" => 2})
      %{data: [%Note{}, ...], paginate: %{current_page: 2, next_page: 3, per_page: 10, prev_page: 1, total_count: 50, total_pages: 5}}

  """
  def paginate_notes_for_user(user_id, criteria \\ %{}) do
    Note |> where(user_id: ^user_id) |> FilteredNotePaginator.paginate(criteria)
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
  end

  @doc """
  Gets a single note for a user.

  Raises `Ecto.NoResultsError` if the Note does not exist.

  ## Examples

      iex> get_note_for_user!(1, 123)
      %Note{}

      iex> get_note_for_user!(1, 456)
      ** (Ecto.NoResultsError)

  """
  def get_note_for_user!(user_id, id) do
    Note
    |> where(user_id: ^user_id)
    |> Repo.get!(id)
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

      iex> update_note(note, %{field: new_value})
      {:ok, %Note{}}

      iex> update_note(note, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_note(%Note{} = note, attrs) do
    note
    |> Note.changeset(attrs)
    |> Repo.update()
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
  def change_note(%Note{} = note) do
    Note.changeset(note, %{})
  end
end
