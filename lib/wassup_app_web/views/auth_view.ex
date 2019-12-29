defmodule WassupAppWeb.AuthView do
  use WassupAppWeb, :view

  import WassupApp.Auth, only: [registration_disabled?: 0]
end
