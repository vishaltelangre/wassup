defmodule WassupAppWeb.PaginateView do
  use WassupAppWeb, :view

  alias WassupAppWeb.NoteLive
  alias WassupAppWeb.Router.Helpers, as: Routes

  @default_options [
    max_page_links: 4,
    previous_label: "⟵",
    first_label: "First",
    next_label: "⟶",
    last_label: "Last"
  ]

  def pagination_links(socket, paginate, options) do
    options = Keyword.merge(@default_options, options)

    content_tag(:nav) do
      content_tag(:ul, class: "pagination") do
        [first_page_link(socket, paginate, options)] ++
          [previous_page_link(socket, paginate, options)] ++
          middle_page_links(socket, paginate, options) ++
          [next_page_link(socket, paginate, options)] ++
          [last_page_link(socket, paginate, options)]
      end
    end
  end

  defp first_page_link(socket, %{current_page: current_page}, options) do
    contents = options[:first_label]

    if current_page == 1 do
      page_link(disabled_page_url(), contents: contents, class: "disabled")
    else
      page_link(generate_page_url(socket, 1), contents: contents)
    end
  end

  defp previous_page_link(
         socket,
         %{current_page: current_page, previous_page: previous_page},
         options
       ) do
    contents = options[:previous_label]

    if current_page <= 1 do
      page_link(disabled_page_url(), contents: contents, class: "disabled")
    else
      page_link(generate_page_url(socket, previous_page), contents: contents)
    end
  end

  defp middle_page_links(socket, paginate, options) do
    max_page_links = options[:max_page_links]
    current_page = paginate.current_page
    max_page = paginate.total_pages

    lower_limit =
      cond do
        current_page <= div(max_page_links, 2) ->
          1

        current_page >= max_page - div(max_page_links, 2) ->
          Enum.max([0, max_page - max_page_links]) + 1

        true ->
          current_page - div(max_page_links, 2)
      end

    upper_limit = lower_limit + max_page_links - 1

    list =
      Enum.map(lower_limit..upper_limit, fn page_number ->
        cond do
          current_page == page_number ->
            page_link(disabled_page_url(), contents: page_number, class: "active")

          page_number > max_page ->
            ""

          true ->
            page_link(generate_page_url(socket, page_number), contents: page_number)
        end
      end)

    # Show the max page link at the end with an elipsis if the total number of
    # pages are more than max page links shown in the view
    # e.g.
    # [1] [2] [3] [...] [12]
    cond do
      max_page - upper_limit == 1 ->
        list ++
          [
            page_link(generate_page_url(socket, max_page),
              contents: max_page
            )
          ]

      max_page - upper_limit > 1 ->
        list ++
          [
            page_link(disabled_page_url(), class: "disabled", contents: "..."),
            page_link(generate_page_url(socket, max_page),
              contents: max_page
            )
          ]

      true ->
        list
    end
  end

  defp next_page_link(socket, paginate, options) do
    contents = options[:next_label]
    current_page = paginate.current_page
    next_page = paginate.next_page
    max_page = paginate.total_pages

    if current_page >= max_page do
      page_link(disabled_page_url(), contents: contents, class: "disabled")
    else
      page_link(generate_page_url(socket, next_page), contents: contents)
    end
  end

  defp last_page_link(socket, %{current_page: current_page, total_pages: total_pages}, options) do
    contents = options[:last_label]

    if current_page == total_pages do
      page_link(disabled_page_url(), contents: contents, class: "disabled")
    else
      page_link(generate_page_url(socket, total_pages), contents: contents)
    end
  end

  defp page_link(url, options) do
    content_tag :li, class: "page-item #{options[:class]}" do
      live_link to: url, class: "page-link", tabindex: -1 do
        options[:contents]
      end
    end
  end

  defp disabled_page_url(), do: "#"

  defp generate_page_url(socket, page_number) do
    filters =
      socket.assigns
      |> Map.take([:q, :period, :per_page])
      |> Map.put(:page, page_number)

    Routes.live_path(socket, NoteLive.Index, %{"filter" => filters})
  end
end
