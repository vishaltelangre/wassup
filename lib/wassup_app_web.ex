defmodule WassupAppWeb do
  @moduledoc """
  The entrypoint for defining your web interface, such
  as controllers, views, channels and so on.

  This can be used in your application as:

      use WassupAppWeb, :controller
      use WassupAppWeb, :view

  The definitions below will be executed for every view,
  controller, etc, so keep them short and clean, focused
  on imports, uses and aliases.

  Do NOT define functions inside the quoted expressions
  below. Instead, define any helper function in modules
  and import those modules here.
  """

  def controller do
    quote do
      use Phoenix.Controller, namespace: WassupAppWeb

      import Plug.Conn
      import WassupAppWeb.Gettext
      import Phoenix.LiveView.Controller
      alias WassupAppWeb.Router.Helpers, as: Routes
    end
  end

  def view do
    quote do
      use Phoenix.View,
        root: "lib/wassup_app_web/templates",
        namespace: WassupAppWeb

      # Import convenience functions from controllers
      import Phoenix.Controller,
        only: [get_csrf_token: 0, get_flash: 1, get_flash: 2, view_module: 1]

      # Use all HTML functionality (forms, tags, etc)
      use Phoenix.HTML

      import WassupAppWeb.ErrorHelpers
      import WassupAppWeb.Gettext
      import Phoenix.LiveView.Helpers
      alias WassupAppWeb.Router.Helpers, as: Routes
    end
  end

  def router do
    quote do
      use Phoenix.Router
      import Plug.Conn
      import Phoenix.Controller
      import Phoenix.LiveView.Router

      import WassupAppWeb.Plugs.Auth,
        only: [
          valid_user: 2,
          ensure_not_signed_in: 2,
          ensure_password_is_set: 2,
          ensure_registration_enabled: 2,
          ensure_account_is_verified: 2
        ]
    end
  end

  def channel do
    quote do
      use Phoenix.Channel
      import WassupAppWeb.Gettext
    end
  end

  @doc """
  When used, dispatch to the appropriate controller/view/etc.
  """
  defmacro __using__(which) when is_atom(which) do
    apply(__MODULE__, which, [])
  end
end
