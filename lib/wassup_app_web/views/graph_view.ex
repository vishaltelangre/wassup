defmodule WassupAppWeb.GraphView do
  use WassupAppWeb, :view

  import WassupAppWeb.SharedView, only: [present?: 1]
  alias WassupApp.PeriodOptions

  def period_option_links(selected_option) do
    PeriodOptions.options()
    |> Enum.map(fn option -> period_option_link(option, selected_option) end)
  end

  def period_option_link(option, selected_option) do
    active_class = if selected_option == option, do: "active", else: ""

    link(option,
      to: {:javascript, "var e = document.querySelector('.period .value');
         e.value='#{option}';
         e.dispatchEvent(new Event('change', {bubbles: true}));"},
      class: "option #{active_class}"
    )
  end
end
