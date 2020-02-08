defmodule WassupAppWeb.NoteComponent.Shared do
  defmacro __using__(_opts) do
    alias WassupApp.Notes.Note

    quote do
      def handle_event("validate", %{"note" => params, "_target" => ["note", "body"]}, socket) do
        %{"body" => body, "sentiment" => sentiment} = params

        params =
          params
          |> Map.put("sentiment", Note.analyze_sentiment_from_text(body, sentiment))

        handle_event("validate", %{"note" => params}, socket)
      end
    end
  end
end
