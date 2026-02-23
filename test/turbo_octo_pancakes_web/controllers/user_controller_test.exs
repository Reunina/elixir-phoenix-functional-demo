defmodule TurboOctoPancakesWeb.UserControllerTest do
  use TurboOctoPancakesWeb.ConnCase, async: true

  alias TurboOctoPancakes.Users.User
  alias TurboOctoPancakes.Repo

  describe "GET /users (unit: with mock context)" do
    @describetag :unit

    setup do
      mock = TurboOctoPancakesWeb.UserControllerTest.MockUsersSuccess
      Application.put_env(:turbo_octo_pancakes, :users_context, mock)
      on_exit(fn -> Application.delete_env(:turbo_octo_pancakes, :users_context) end)
      :ok
    end

    test "returns 200 and JSON with users list from context", %{conn: conn} do
      conn = get(conn, ~p"/users")

      assert json_response(conn, 200) == %{
               "users" => [
                 %{"id" => "mock-id-1", "first_name" => "Mock", "last_name" => "User"}
               ]
             }
    end

    test "returns 500 and error JSON when context returns error", %{conn: conn} do
      Application.put_env(
        :turbo_octo_pancakes,
        :users_context,
        TurboOctoPancakesWeb.UserControllerTest.MockUsersError
      )

      conn = get(conn, ~p"/users")
      assert json_response(conn, 500) == %{"error" => %{"message" => "Internal server error"}}
    end
  end

  describe "GET /users (integration: real context and DB)" do
    @describetag :integration

    test "returns 200 and empty users when no users", %{conn: conn} do
      conn = get(conn, ~p"/users")
      assert json_response(conn, 200) == %{"users" => []}
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
      assert %{"users" => users} = body
      assert length(users) == 2
      [first, second] = users
      assert first["first_name"] == "Alice"
      assert first["last_name"] == "Beta"
      assert second["first_name"] == "Zara"
      assert second["last_name"] == "Alpha"
      assert first["id"] == u2.id
      assert second["id"] == u1.id
    end
  end

  defmodule MockUsersSuccess do
    @behaviour TurboOctoPancakes.Users.Behaviour

    @impl true
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
    @behaviour TurboOctoPancakes.Users.Behaviour

    @impl true
    def list_users(_opts), do: {:error, :forced}

    def list_users, do: list_users(%{})
  end
end
