defmodule TurboOctoPancakes.Users.Currency do
  @moduledoc """
  The Currency schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          code: String.t() | nil,
          decimal: integer() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:code, :string, autogenerate: false}

  schema "currencies" do
    field :decimal, :integer, default: 2

    timestamps(type: :utc_datetime)
  end

  @required_fields [:code]
  @optional_fields [:decimal]

  @doc false
  def changeset(currency, attrs) do
    currency
    |> cast(attrs, @required_fields ++ @optional_fields)
    |> validate_required(@required_fields)
    |> validate_length(:code, is: 3)
    |> validate_number(:decimal, greater_than_or_equal_to: 0)
    |> unique_constraint(:code, name: :currencies_pkey)
  end
end
