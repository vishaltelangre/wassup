defmodule WassupApp.Notes.Note do
  use WassupApp.BaseModel

  alias WassupApp.Accounts.User

  import EctoEnum

  @derive {Jason.Encoder, only: [:id, :body, :sentiment, :favorite, :submitted_at]}

  @sentiment_details %{
    sad: %{value: 1, color: "#e55"},
    neutral: %{value: 2, color: "#aac"},
    happy: %{value: 3, color: "#5c5"}
  }

  defenum(SentimentEnum, @sentiment_details |> Map.keys() |> Enum.map(&to_string/1))

  schema "notes" do
    field :body, :string
    field :favorite, :boolean, default: false
    field :sentiment, SentimentEnum
    field :submitted_at, :utc_datetime
    belongs_to :user, User

    timestamps()
  end

  def sentiment_details, do: @sentiment_details

  def sentiment_value(sentiment) do
    Map.fetch!(sentiment_details(), sentiment).value
  end

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:body, :favorite, :sentiment, :submitted_at])
    |> validate_required([:body, :favorite, :sentiment])
  end
end
