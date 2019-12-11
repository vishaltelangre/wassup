defmodule WassupApp.Notes.Note do
  use WassupApp.BaseModel

  alias WassupApp.Accounts.User

  import EctoEnum

  @sentiments ~w(happy neutral bored sad)

  defenum(SentimentEnum, @sentiments)

  schema "notes" do
    field :body, :string
    field :favorite, :boolean, default: false
    field :sentiment, SentimentEnum
    field :submitted_at, :utc_datetime
    belongs_to :user, User

    timestamps()
  end

  def sentiments, do: @sentiments

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:body, :favorite, :sentiment, :submitted_at])
    |> validate_required([:body, :favorite, :sentiment])
  end
end
