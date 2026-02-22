defmodule TurboOctoPancakesWeb.UserController do
  use TurboOctoPancakesWeb, :controller

  alias TurboOctoPancakesWeb.UserJSON

  def index(conn, params) do
    opts =
      %{}
      |> add_filter(:name, params["name"])
      |> add_order(order_by: :by_name)

    case users_context().list_users(opts) do
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

  defp add_filter(opts, :name, nil), do: opts
  defp add_filter(opts, :name, ""), do: opts

  defp add_filter(opts, :name, value) when is_binary(value),
    do: Map.put(opts, :filter, %{by_name: String.trim(value)})

  defp add_filter(opts, _key, _value), do: opts

  defp add_order(opts, order_by: fields), do: Map.put(opts, :order, fields)

  defp users_context,
    do: Application.get_env(:turbo_octo_pancakes, :users_context, TurboOctoPancakes.Users)
end
