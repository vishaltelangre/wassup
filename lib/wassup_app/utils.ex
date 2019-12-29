defmodule WassupApp.Utils do
  def get_env(var) do
    case var do
      {:system, varname} -> System.get_env(varname)
      value -> value
    end
  end
end
