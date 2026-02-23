defmodule TurboOctoPancakesWeb.UserController do
  use TurboOctoPancakesWeb, :controller

  alias TurboOctoPancakesWeb.UserJSON

  def index(conn, _params) do
    opt =
      %{}
      |> Map.put(:order, :by_name)

    case users_context().list_users(opt) do
      {:ok, users} ->
        conn
        |> put_status(:ok)
        |> json(UserJSON.index(%{users: users}))

      {:error, _reason} ->
        conn
        |> put_status(:internal_server_error)
        |> json(UserJSON.error(%{message: "Internal server error"}))
    end
  end

  defp users_context,
    do: Application.get_env(:turbo_octo_pancakes, :users_context, TurboOctoPancakes.Users)
end
