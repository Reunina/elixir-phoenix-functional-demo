defmodule TurboOctoPancakes.UsersTest do
  use TurboOctoPancakes.DataCase, async: true

  alias TurboOctoPancakes.Users
  alias TurboOctoPancakes.Users.User
  alias TurboOctoPancakes.Repo

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

    test "returns {:error, _} when repo raises" do
      original = Application.get_env(:turbo_octo_pancakes, :repo)
      Application.put_env(:turbo_octo_pancakes, :repo, FakeFailingRepo)

      on_exit(fn ->
        if original,
          do: Application.put_env(:turbo_octo_pancakes, :repo, original),
          else: Application.delete_env(:turbo_octo_pancakes, :repo)
      end)

      assert {:error, _} = Users.list_users()
    end
  end
end

defmodule FakeFailingRepo do
  def all(_query), do: raise("repo failure")
end
