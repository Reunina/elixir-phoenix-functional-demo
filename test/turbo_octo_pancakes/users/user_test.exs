defmodule TurboOctoPancakes.Users.UserTest do
  use TurboOctoPancakes.DataCase, async: true

  alias TurboOctoPancakes.Users.User

  describe "changeset/2" do
    test "valid attributes produce a valid changeset" do
      attrs = %{first_name: "Jane", last_name: "Doe"}
      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :first_name) == "Jane"
      assert get_change(changeset, :last_name) == "Doe"
    end

    test "missing first_name is invalid" do
      attrs = %{last_name: "Doe"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert %{first_name: ["can't be blank"]} = errors_on(changeset)
    end

    test "missing last_name is invalid" do
      attrs = %{first_name: "Jane"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert %{last_name: ["can't be blank"]} = errors_on(changeset)
    end

    test "empty string first_name is invalid" do
      attrs = %{first_name: "", last_name: "Doe"}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert %{first_name: ["can't be blank"]} = errors_on(changeset)
    end

    test "empty string last_name is invalid" do
      attrs = %{first_name: "Jane", last_name: ""}
      changeset = User.changeset(%User{}, attrs)

      refute changeset.valid?
      assert %{last_name: ["can't be blank"]} = errors_on(changeset)
    end

    test "unknown attributes are ignored" do
      attrs = %{first_name: "Jane", last_name: "Doe", unknown: "ignored"}
      changeset = User.changeset(%User{}, attrs)

      assert changeset.valid?
      assert get_change(changeset, :unknown) == nil
    end
  end
end
