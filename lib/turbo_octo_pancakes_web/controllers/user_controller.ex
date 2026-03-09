defmodule TurboOctoPancakesWeb.UserController do
  use TurboOctoPancakesWeb, :controller
  use PhoenixSwagger

  alias PhoenixSwagger.Schema
  alias TurboOctoPancakesWeb.UserJSON

  swagger_path :index do
    get("/users")
    summary("List users")

    description(
      "Returns all users ordered by full name (first_name then last_name), " <>
        "optionally filtered by name and whether they have active products."
    )

    tag("Users")

    parameters do
      name(
        :query,
        :string,
        "Filter users by first name, last name, or full name (case-insensitive)",
        required: false
      )

      has_active_product(
        :query,
        :boolean,
        "Filter users by whether they have at least one active product. " <>
          "Use true for only users with active products and false for users without active products.",
        required: false
      )
    end

    response(200, "OK", Schema.ref(:UsersIndexResponse))
    response(500, "Internal server error", Schema.ref(:ErrorResponse))
  end

  def index(conn, params) do
    opts =
      %{}
      |> add_filter(:name, params["name"])
      |> add_filter(:has_active_product, params["has_active_product"])
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
    do: put_filter(opts, :by_name, String.trim(value))

  defp add_filter(opts, :has_active_product, nil), do: opts

  defp add_filter(opts, :has_active_product, ""), do: opts

  defp add_filter(opts, :has_active_product, value) when is_binary(value) do
    case parse_boolean(value) do
      nil -> opts
      bool -> put_filter(opts, :has_active_product, bool)
    end
  end

  defp add_filter(opts, _key, _value), do: opts

  defp put_filter(opts, key, value) do
    filters = Map.get(opts, :filter, %{})
    Map.put(opts, :filter, Map.put(filters, key, value))
  end

  defp parse_boolean(value) when is_binary(value) do
    case String.downcase(String.trim(value)) do
      "true" -> true
      "false" -> false
      _ -> nil
    end
  end

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
            products(Schema.array(:Product), "List of user products", required: true)
          end

          example(%{
            id: "mock-id-1",
            first_name: "Mock",
            last_name: "User",
            products: [
              %{
                id: "product-id-1",
                label: "Base product",
                amount: 100_000,
                stock: 0,
                currency: "USD",
                start_date: "2025-01-01T00:00:00Z",
                end_date: nil
              }
            ]
          })
        end,
      Product:
        swagger_schema do
          title("Product")
          description("A prouct entry for a user")

          properties do
            id(:string, "Product ID", required: true)
            label(:string, "Product label", required: true)
            amount(:integer, "Product amount in minor units (e.g. cents)", required: true)
            stock(:integer, "Associated stock units", required: true)
            currency(:string, "ISO 4217 currency code", required: true)
            start_date(:string, "Start date (ISO8601)", required: true)
            end_date(:string, "End date (ISO8601)", required: false)
          end
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
