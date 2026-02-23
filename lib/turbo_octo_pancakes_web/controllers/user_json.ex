defmodule TurboOctoPancakesWeb.UserJSON do
  @moduledoc """
  JSON rendering for UserController responses.
  """

  def index(%{users: users}) do
    %{users: Enum.map(users, &user/1)}
  end

  def error(%{message: message}) do
    %{error: %{message: message}}
  end

  defp user(%{id: id, first_name: first_name, last_name: last_name}) do
    %{id: id, first_name: first_name, last_name: last_name}
  end
end
