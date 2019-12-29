defmodule WassupApp.Auth do
  alias WassupApp.Utils

  import Plug.Conn
  import Phoenix.Controller
  alias WassupAppWeb.Router.Helpers, as: Routes

  def registration_disabled?() do
    Utils.get_env({:system, "REGISTRATION_DISABLED"}) == "true"
  end

  def ensure_registration_enabled(conn) do
    if registration_disabled?() do
      conn
      |> put_flash(
        :info,
        "Sorry! Registration is not enabled at this moment. Please contact the administrator."
      )
      |> redirect(to: Routes.login_path(conn, :request))
      |> halt()
    else
      conn
    end
  end
end
