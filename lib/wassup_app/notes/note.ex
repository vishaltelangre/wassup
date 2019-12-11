defmodule WassupApp.Notes.Note do
  use WassupApp.BaseModel

  alias WassupApp.Accounts.User

  schema "notes" do
    field :body, :string
    field :favorite, :boolean, default: false
    field :sentiment, SentimentEnum
    field :submitted_at, :naive_datetime
    belongs_to :user, User

    timestamps()
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:body, :favorite, :sentiment, :submitted_at])
    |> validate_required([:body, :favorite, :sentiment])
  end
end
