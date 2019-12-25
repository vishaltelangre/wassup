defmodule WassupApp.Notes.Note do
  use WassupApp.BaseModel

  alias WassupApp.Accounts.User
  alias WassupApp.Notes.Note

  import EctoEnum

  @derive {Jason.Encoder,
           only: [
             :id,
             :body,
             :sentiment,
             :sentiment_value,
             :sentiment_color,
             :favorite,
             :favorite_icon_path,
             :submitted_at
           ]}

  @sentiment_details %{
    sad: %{value: 1, color: "#e55"},
    neutral: %{value: 2, color: "#aac"},
    happy: %{value: 3, color: "#5c5"}
  }

  defenum(SentimentEnum, @sentiment_details |> Map.keys() |> Enum.map(&to_string/1))

  schema "notes" do
    field :body, :string
    field :favorite, :boolean, default: false
    field :favorite_icon_path, :string, virtual: true
    field :sentiment, SentimentEnum
    field :sentiment_value, :string, virtual: true
    field :sentiment_color, :string, virtual: true
    field :submitted_at, :utc_datetime
    belongs_to :user, User

    timestamps()
  end

  def transform_fields(%Note{sentiment: sentiment, favorite: favorite} = note, timezone \\ nil) do
    note
    |> maybe_transform_submitted_at_in_timezone(timezone)
    |> Map.put(:sentiment_value, sentiment_value(sentiment))
    |> Map.put(:sentiment_color, sentiment_color(sentiment))
    |> Map.put(:favorite_icon_path, favorite && "/images/favorite.svg")
  end

  defp maybe_transform_submitted_at_in_timezone(note, nil), do: note

  defp maybe_transform_submitted_at_in_timezone(
         %Note{submitted_at: submitted_at} = note,
         timezone
       ) do
    note |> Map.put(:submitted_at, submitted_at |> Timex.to_datetime(timezone))
  end

  defp sentiment_value(sentiment) do
    Map.fetch!(sentiment_details(), sentiment).value
  end

  defp sentiment_color(sentiment) do
    Map.fetch!(sentiment_details(), sentiment).color
  end

  def sentiment_details, do: @sentiment_details

  @doc false
  def changeset(note, attrs) do
    note
    |> cast(attrs, [:body, :favorite, :sentiment, :submitted_at])
    |> validate_required([:body, :favorite, :sentiment])
  end
end
