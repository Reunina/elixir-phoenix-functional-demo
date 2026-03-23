defmodule ElixirPhoenixFunctionalDemoWeb.UserControllerTest do
  use ElixirPhoenixFunctionalDemoWeb.ConnCase, async: true

  alias ElixirPhoenixFunctionalDemo.Users.User
  alias ElixirPhoenixFunctionalDemo.Repo

  describe "GET /users (unit: with mock context)" do
    @describetag :unit

    setup do
      mock = ElixirPhoenixFunctionalDemoWeb.UserControllerTest.MockUsersSuccess
      Application.put_env(:elixir_phoenix_functional_demo, :users_context, mock)
      on_exit(fn -> Application.delete_env(:elixir_phoenix_functional_demo, :users_context) end)
      :ok
    end

    test "returns 200 and JSON with users list from context", %{conn: conn} do
      conn = get(conn, ~p"/users")

      assert json_response(conn, 200) == %{
               "users" => [
                 %{
                   "id" => "mock-id-1",
                   "first_name" => "Mock",
                   "last_name" => "User",
                   "products" => []
                 }
               ],
               "pagination" => %{
                 "page" => 1,
                 "per_page" => 20,
                 "total" => 1,
                 "total_pages" => 1
               }
             }
    end

    test "passes name param to context and returns filtered result", %{conn: conn} do
      conn = get(conn, ~p"/users?name=alice")

      assert json_response(conn, 200) == %{
               "users" => [
                 %{
                   "id" => "filtered-id",
                   "first_name" => "Alice",
                   "last_name" => "Filtered",
                   "products" => []
                 }
               ],
               "pagination" => %{
                 "page" => 1,
                 "per_page" => 20,
                 "total" => 1,
                 "total_pages" => 1
               }
             }
    end

    test "passes name param (trimmed) to context and returns filtered result", %{conn: conn} do
      conn = get(conn, ~p"/users?name=%20alice")

      assert json_response(conn, 200) == %{
               "users" => [
                 %{
                   "id" => "filtered-id",
                   "first_name" => "Alice",
                   "last_name" => "Filtered",
                   "products" => []
                 }
               ],
               "pagination" => %{
                 "page" => 1,
                 "per_page" => 20,
                 "total" => 1,
                 "total_pages" => 1
               }
             }
    end

    test "passes has_active_product=true param to context and returns filtered result", %{
      conn: conn
    } do
      conn = get(conn, ~p"/users?has_active_product=true")

      assert json_response(conn, 200) == %{
               "users" => [
                 %{
                   "id" => "active-product-id",
                   "first_name" => "Has",
                   "last_name" => "ActiveProduct",
                   "products" => []
                 }
               ],
               "pagination" => %{
                 "page" => 1,
                 "per_page" => 20,
                 "total" => 1,
                 "total_pages" => 1
               }
             }
    end

    test "returns 500 and error JSON when context returns error", %{conn: conn} do
      Application.put_env(
        :elixir_phoenix_functional_demo,
        :users_context,
        ElixirPhoenixFunctionalDemoWeb.UserControllerTest.MockUsersError
      )

      conn = get(conn, ~p"/users")
      assert json_response(conn, 500) == %{"error" => %{"message" => "Internal server error"}}
    end
  end

  describe "POST /users/invite-users (unit: with mock context)" do
    @describetag :unit

    setup do
      mock = ElixirPhoenixFunctionalDemoWeb.UserControllerTest.MockUsersSuccess
      Application.put_env(:elixir_phoenix_functional_demo, :users_context, mock)
      on_exit(fn -> Application.delete_env(:elixir_phoenix_functional_demo, :users_context) end)
      :ok
    end

    test "returns 202 and invited users payload with ids", %{conn: conn} do
      conn = post(conn, ~p"/users/invite-users")

      assert json_response(conn, 202) == %{
               "invited_users" => %{
                 "total" => 1,
                 "ids" => ["active-product-id"]
               }
             }
    end
  end

  describe "GET /users (integration: real context and DB)" do
    @describetag :integration

    test "returns 200 and empty users when no users", %{conn: conn} do
      conn = get(conn, ~p"/users")

      assert json_response(conn, 200) == %{
               "users" => [],
               "pagination" => %{
                 "page" => 1,
                 "per_page" => 20,
                 "total" => 0,
                 "total_pages" => 0
               }
             }
    end

    test "returns 200 and all users ordered by full name", %{conn: conn} do
      u1 =
        %User{}
        |> User.changeset(%{first_name: "Zara", last_name: "Alpha"})
        |> Repo.insert!()

      u2 =
        %User{}
        |> User.changeset(%{first_name: "Alice", last_name: "Beta"})
        |> Repo.insert!()

      conn = get(conn, ~p"/users")
      body = json_response(conn, 200)
      assert %{"users" => users, "pagination" => pagination} = body
      assert length(users) == 2

      assert pagination == %{
               "page" => 1,
               "per_page" => 20,
               "total" => 2,
               "total_pages" => 1
             }

      [first, second] = users
      assert first["first_name"] == "Alice"
      assert first["last_name"] == "Beta"
      assert second["first_name"] == "Zara"
      assert second["last_name"] == "Alpha"
      assert first["id"] == u2.id
      assert second["id"] == u1.id
      assert first["products"] == []
      assert second["products"] == []
    end

    test "filters by name query param", %{conn: conn} do
      %User{}
      |> User.changeset(%{first_name: "Other", last_name: "User"})
      |> Repo.insert!()

      jane =
        %User{}
        |> User.changeset(%{first_name: "Jane", last_name: "Doe"})
        |> Repo.insert!()

      conn = get(conn, ~p"/users?name=Jane")
      body = json_response(conn, 200)

      assert %{
               "users" => [user],
               "pagination" => %{
                 "page" => 1,
                 "per_page" => 20,
                 "total" => 1,
                 "total_pages" => 1
               }
             } = body

      assert user["id"] == jane.id
      assert user["first_name"] == "Jane"
      assert user["last_name"] == "Doe"
      assert user["products"] == []
    end

    test "supports pagination params", %{conn: conn} do
      %User{} |> User.changeset(%{first_name: "Anna", last_name: "Zero"}) |> Repo.insert!()
      %User{} |> User.changeset(%{first_name: "Bella", last_name: "One"}) |> Repo.insert!()
      %User{} |> User.changeset(%{first_name: "Cara", last_name: "Two"}) |> Repo.insert!()

      conn = get(conn, ~p"/users?page=2&per_page=1")
      body = json_response(conn, 200)

      assert %{
               "users" => [user],
               "pagination" => %{
                 "page" => 2,
                 "per_page" => 1,
                 "total" => 3,
                 "total_pages" => 3
               }
             } = body

      assert user["first_name"] == "Bella"
    end
  end

  defmodule MockUsersSuccess do
    @behaviour ElixirPhoenixFunctionalDemo.Users.Behaviour

    @impl true
    def list_users(%{filter: %{by_name: "alice"}}) do
      {:ok,
       [
         %User{
           id: "filtered-id",
           first_name: "Alice",
           last_name: "Filtered",
           inserted_at: nil,
           updated_at: nil
         }
       ]}
    end

    def list_users(%{filter: %{has_active_product: true}}) do
      {:ok,
       [
         %User{
           id: "active-product-id",
           first_name: "Has",
           last_name: "ActiveProduct",
           inserted_at: nil,
           updated_at: nil
         }
       ]}
    end

    def list_users(_opts) do
      {:ok,
       [
         %User{
           id: "mock-id-1",
           first_name: "Mock",
           last_name: "User",
           inserted_at: nil,
           updated_at: nil
         }
       ]}
    end

    def list_users, do: list_users(%{})
  end

  defmodule MockUsersError do
    @behaviour ElixirPhoenixFunctionalDemo.Users.Behaviour

    @impl true
    def list_users(_opts), do: {:error, :forced}

    def list_users, do: list_users(%{})
  end
end
