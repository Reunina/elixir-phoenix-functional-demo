defmodule TurboOctoPancakes.Users.Product do
  @moduledoc """
  The Product schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  alias TurboOctoPancakes.Users.User
  alias TurboOctoPancakes.Users.Currency

  @type t :: %__MODULE__{
          id: binary() | nil,
          user_id: binary() | nil,
          user: User.t() | Ecto.Association.NotLoaded.t(),
          currency_code: String.t() | nil,
          currency: Currency.t() | Ecto.Association.NotLoaded.t(),
          price: integer() | nil,
          stock: integer() | nil,
          label: String.t() | nil,
          start_date: DateTime.t() | nil,
          end_date: DateTime.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}
  @foreign_key_type :binary_id

  schema "products" do
    field :price, :integer
    field :stock, :integer
    field :label, :string
    field :start_date, :utc_datetime
    field :end_date, :utc_datetime

    belongs_to :user, User
    belongs_to :currency, Currency, foreign_key: :currency_code, references: :code, type: :string

    timestamps(type: :utc_datetime)
  end

  @required_fields [:user_id, :currency_code, :price, :stock, :label, :start_date]
  @optional_fields [:end_date]

  @spec changeset(
          {map(),
           %{
             optional(atom()) =>
               atom()
               | {:array | :assoc | :embed | :in | :map | :parameterized | :supertype | :try,
                  any()}
           }}
          | %{
              :__struct__ => atom() | %{:__changeset__ => any(), optional(any()) => any()},
              optional(atom()) => any()
            },
          :invalid | %{optional(:__struct__) => none(), optional(atom() | binary()) => any()}
        ) :: Ecto.Changeset.t()
  @doc false
  def changeset(product, attrs) do
    product
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_number(:price, greater_than: 0)
    |> validate_number(:stock, greater_than: 0)
    |> foreign_key_constraint(:user_id)
    |> foreign_key_constraint(:currency_code)
  end
end
