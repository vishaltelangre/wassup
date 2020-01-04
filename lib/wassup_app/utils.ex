defmodule WassupApp.Utils do
  def get_env(var) do
    case var do
      {:system, varname} -> System.get_env(varname)
      varname -> System.get_env(varname)
    end
  end

  def get_env(var, default_value) do
    case var do
      {:system, varname} ->
        case System.get_env(varname) |> to_string() |> String.trim() do
          "" -> default_value
          value -> value
        end

      varname ->
        System.get_env(varname)
    end
  end

  def app_name() do
    get_env({:system, "APP_NAME"}, "Wassup")
  end

  def app_hostname do
    get_env({:system, "APP_HOSTNAME"}) ||
      to_string(get_env({:system, "HEROKU_APP_NAME"})) <> "herokuapp.com"
  end

  def app_url do
    get_env({:system, "APP_URL"}) || "https://" <> app_hostname()
  end

  def demo_instance?() do
    get_env({:system, "DEMO"}) == "true"
  end

  def mail_sender_email() do
    get_env({:system, "MAIL_SENDER_EMAIL"}, "support@wassupapp.com")
  end

  def google_analytics_tracking_id do
    get_env({:system, "GOOGLE_ANALYTICS_TRACKING_ID"})
  end
end
