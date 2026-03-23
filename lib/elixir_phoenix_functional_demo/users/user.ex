defmodule ElixirPhoenixFunctionalDemo.Users.User do
  @moduledoc """
  The User schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias ElixirPhoenixFunctionalDemo.Users.Product

  @type t :: %__MODULE__{
          id: binary() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          products: [Product.t()] | Ecto.Association.NotLoaded.t(),
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :first_name, :string
    field :last_name, :string

    has_many :products, Product

    timestamps(type: :utc_datetime_usec)
  end

  @required_fields [:first_name, :last_name]

  @doc false
  def changeset(user, attrs) do
    user
    |> cast(attrs, @required_fields)
    |> validate_required(@required_fields)
  end
end
