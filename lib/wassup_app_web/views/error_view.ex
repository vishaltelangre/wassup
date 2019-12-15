defmodule WassupAppWeb.ErrorView do
  use WassupAppWeb, :view

  # If you want to customize a particular status code
  # for a certain format, you may uncomment below.
  # def render("500.html", _assigns) do
  #   "Internal Server Error"
  # end

  # By default, Phoenix returns the status message from
  # the template name. For example, "404.html" becomes
  # "Not Found".
  def template_not_found(template, _assigns) do
    Phoenix.Controller.status_message_from_template(template)
  end

  def translate_errors(changeset) do
    Ecto.Changeset.traverse_errors(changeset, &translate_error/1)
  end

  def render("error.json", %{changeset: changeset}) do
    # When encoded, the changeset returns its errors
    # as a JSON object. So we just pass it forward.
    %{errors: translate_errors(changeset)}
  end
end
