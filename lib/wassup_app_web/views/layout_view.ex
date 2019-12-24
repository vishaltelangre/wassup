defmodule WassupAppWeb.LayoutView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [sentiment_details: 0]

  def logged_in_user_name(user) do
    user.name |> String.split(" ") |> hd
  end
end
