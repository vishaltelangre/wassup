defmodule WassupApp.Notes.FilteredNotePaginator do
  import Ecto.Query
  alias WassupApp.Repo
  alias WassupApp.Notes.Note

  @default_criteria %{
    "q" => "",
    "period" => "",
    "timezone" => "Etc/UTC",
    "per_page" => 10,
    "page" => 1
  }

  def paginate(criteria), do: paginate(Note, criteria)

  def paginate(query, criteria) do
    criteria = Map.merge(@default_criteria, criteria) |> format_criteria

    %{
      data: rebuild_query(query, criteria) |> Repo.all(),
      paginate: pagination_information(query, criteria)
    }
  end

  defp rebuild_query(query, %{
         "q" => q,
         "period" => period,
         "timezone" => timezone,
         "per_page" => per_page,
         "page" => page
       }) do
    query
    |> maybe_between_period(period, timezone)
    |> maybe_search_condition(q)
    |> order_by(desc: :submitted_at)
    |> limit(^per_page)
    |> offset((^page - 1) * ^per_page)
  end

  defp maybe_between_period(query, "", _timezone), do: query

  defp maybe_between_period(query, period, timezone) do
    [from, to] = String.split(period, "-", trim: true)
    from = parse_period_date(from, timezone) |> Timex.beginning_of_day()
    to = parse_period_date(to, timezone) |> Timex.end_of_day()

    query |> where([n], n.submitted_at >= ^from and n.submitted_at <= ^to)
  end

  defp parse_period_date(date, timezone) do
    String.trim(date)
    |> Timex.parse!("%b %e, %Y", :strftime)
    |> Timex.to_datetime(timezone)
  end

  defp maybe_search_condition(query, ""), do: query

  defp maybe_search_condition(query, q) do
    query |> where([n], ilike(n.body, ^"%#{q}%"))
  end

  def pagination_information(query, criteria = %{"per_page" => per_page, "page" => page}) do
    total_count = get_total_count(query, criteria)

    total_pages =
      total_count
      |> (&(&1 / per_page)).()
      |> Float.ceil()
      |> trunc()

    next_page = if total_pages - page >= 1, do: page + 1, else: nil

    previous_page = if total_pages >= page && page > 1, do: page - 1, else: nil

    %{
      current_page: page,
      per_page: per_page,
      total_count: total_count,
      total_pages: total_pages,
      next_page: next_page,
      previous_page: previous_page
    }
  end

  defp get_total_count(query, criteria) do
    rebuild_query(query, criteria)
    |> exclude(:select)
    |> exclude(:preload)
    |> exclude(:order_by)
    |> exclude(:limit)
    |> exclude(:offset)
    |> Repo.aggregate(:count, :id)
  end

  defp format_criteria(criteria) do
    criteria
    |> Map.put("per_page", format_integer(Map.get(criteria, "per_page")))
    |> Map.put("page", format_integer(Map.get(criteria, "page")))
    |> Map.put("q", String.trim(Map.get(criteria, "q")))
  end

  defp format_integer(value) do
    if is_integer(value), do: value, else: String.to_integer(value)
  end
end
