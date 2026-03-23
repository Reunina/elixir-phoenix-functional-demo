defmodule ElixirPhoenixFunctionalDemo.UsersTest do
  use ElixirPhoenixFunctionalDemo.DataCase, async: true

  alias ElixirPhoenixFunctionalDemo.Users
  alias ElixirPhoenixFunctionalDemo.Users.User
  alias ElixirPhoenixFunctionalDemo.Users.Product
  alias ElixirPhoenixFunctionalDemo.Users.Currency
  alias ElixirPhoenixFunctionalDemo.Repo

  describe "list_users/1" do
    test "returns empty list when no users exist" do
      assert {:ok, []} = Users.list_users()
    end

    test "returns all users ordered by full name (first_name then last_name)" do
      zara =
        %User{}
        |> User.changeset(%{first_name: "Zara", last_name: "Alpha"})
        |> Repo.insert!()

      alice =
        %User{}
        |> User.changeset(%{first_name: "Alice", last_name: "Beta"})
        |> Repo.insert!()

      bob =
        %User{}
        |> User.changeset(%{first_name: "Bob", last_name: "Alpha"})
        |> Repo.insert!()

      assert {:ok, users} = Users.list_users(%{order: :by_name})
      ids = Enum.map(users, & &1.id)
      assert ids == [alice.id, bob.id, zara.id]
    end

    test "filters by name (first_name)" do
      _other =
        %User{}
        |> User.changeset(%{first_name: "Other", last_name: "User"})
        |> Repo.insert!()

      jane =
        %User{}
        |> User.changeset(%{first_name: "Jane", last_name: "Doe"})
        |> Repo.insert!()

      assert {:ok, users} = Users.list_users(%{filter: %{by_name: "Jane"}})
      assert length(users) == 1
      assert hd(users).id == jane.id
    end

    test "filters by name (last_name)" do
      _other =
        %User{}
        |> User.changeset(%{first_name: "Other", last_name: "User"})
        |> Repo.insert!()

      jane =
        %User{}
        |> User.changeset(%{first_name: "Jane", last_name: "Doe"})
        |> Repo.insert!()

      assert {:ok, users} = Users.list_users(%{filter: %{by_name: "Doe"}})
      assert length(users) == 1
      assert hd(users).id == jane.id
    end

    test "filters by name (full name)" do
      jane =
        %User{}
        |> User.changeset(%{first_name: "Jane", last_name: "Doe"})
        |> Repo.insert!()

      assert {:ok, users} = Users.list_users(%{filter: %{by_name: "Jane Doe"}})
      assert length(users) == 1
      assert hd(users).id == jane.id
    end

    test "name filter is case insensitive" do
      jane =
        %User{}
        |> User.changeset(%{first_name: "Jane", last_name: "Doe"})
        |> Repo.insert!()

      assert {:ok, users} = Users.list_users(%{filter: %{by_name: "jane"}})
      assert length(users) == 1
      assert hd(users).id == jane.id
    end

    test "returns {:error, _} when repo raises" do
      original = Application.get_env(:elixir_phoenix_functional_demo, :repo)
      Application.put_env(:elixir_phoenix_functional_demo, :repo, FakeFailingRepo)

      on_exit(fn ->
        if original,
          do: Application.put_env(:elixir_phoenix_functional_demo, :repo, original),
          else: Application.delete_env(:elixir_phoenix_functional_demo, :repo)
      end)

      assert {:error, _} = Users.list_users()
    end

    test "preloads products for each user" do
      %Currency{}
      |> Currency.changeset(%{code: "USD"})
      |> Repo.insert!()

      user =
        %User{}
        |> User.changeset(%{first_name: "Jane", last_name: "Doe"})
        |> Repo.insert!()

      %Product{}
      |> Product.changeset(%{
        user_id: user.id,
        currency_code: "USD",
        price: 100,
        stock: 2,
        label: "Label",
        start_date: DateTime.utc_now()
      })
      |> Repo.insert!()

      assert {:ok, users} = Users.list_users()
      assert length(users) == 1

      [loaded_user] = users
      assert loaded_user.id == user.id
      assert match?([%Product{}], loaded_user.products)
    end

    test "filters by has_active_product=true based on end_date" do
      %Currency{}
      |> Currency.changeset(%{code: "USD"})
      |> Repo.insert!()

      no_products_user =
        %User{}
        |> User.changeset(%{first_name: "No", last_name: "Products"})
        |> Repo.insert!()

      only_ended_user =
        %User{}
        |> User.changeset(%{first_name: "Only", last_name: "Ended"})
        |> Repo.insert!()

      active_user =
        %User{}
        |> User.changeset(%{first_name: "Has", last_name: "Active"})
        |> Repo.insert!()

      now = DateTime.utc_now()
      past = DateTime.add(now, -86_400, :second)

      %Product{}
      |> Product.changeset(%{
        user_id: only_ended_user.id,
        currency_code: "USD",
        price: 100,
        stock: 1,
        label: "Ended",
        start_date: past,
        end_date: past
      })
      |> Repo.insert!()

      %Product{}
      |> Product.changeset(%{
        user_id: active_user.id,
        currency_code: "USD",
        price: 100,
        stock: 1,
        label: "Active",
        start_date: now,
        end_date: nil
      })
      |> Repo.insert!()

      assert {:ok, users} = Users.list_users(%{filter: %{has_active_product: true}})
      assert Enum.map(users, & &1.id) == [active_user.id]
      refute no_products_user.id in Enum.map(users, & &1.id)
      refute only_ended_user.id in Enum.map(users, & &1.id)
    end
  end
end

defmodule FakeFailingRepo do
  def all(_query), do: raise("repo failure")
end
