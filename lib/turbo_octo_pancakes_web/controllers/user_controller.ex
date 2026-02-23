defmodule TurboOctoPancakesWeb.UserController do
  use TurboOctoPancakesWeb, :controller
  use PhoenixSwagger

  alias PhoenixSwagger.Schema
  alias TurboOctoPancakesWeb.UserJSON

  swagger_path :index do
    get("/users")
    summary("List users")
    description("Returns all users ordered by full name (first_name then last_name).")
    tag("Users")

    parameters do
      name(:query, :string, "Filter users by first name, last name, or full name (case-insensitive)", required: false)
    end

    response(200, "OK", Schema.ref(:UsersIndexResponse))
    response(500, "Internal server error", Schema.ref(:ErrorResponse))
  end

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

  def swagger_definitions do
    %{
      User:
        swagger_schema do
          title("User")
          description("A user in the system")

          properties do
            id(:string, "User ID", required: true)
            first_name(:string, "First name", required: true)
            last_name(:string, "Last name", required: true)
          end

          example(%{
            id: "mock-id-1",
            first_name: "Mock",
            last_name: "User"
          })
        end,
      UsersIndexResponse:
        swagger_schema do
          title("Users index response")

          properties do
            users(Schema.array(:User), "List of users", required: true)
          end
        end,
      ErrorResponse:
        swagger_schema do
          title("Error response wrapper")

          properties do
            error(Schema.ref(:ErrorObject), "Error payload", required: true)
          end
        end,
      ErrorObject:
        swagger_schema do
          title("Error")

          properties do
            message(:string, "Error message", required: true)
          end
        end
    }
  end
end
