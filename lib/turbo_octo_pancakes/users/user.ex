defmodule TurboOctoPancakes.Users.User do
  @moduledoc """
  The User schema.
  """

  use Ecto.Schema
  import Ecto.Changeset

  @type t :: %__MODULE__{
          id: binary() | nil,
          first_name: String.t() | nil,
          last_name: String.t() | nil,
          inserted_at: DateTime.t() | nil,
          updated_at: DateTime.t() | nil
        }

  @primary_key {:id, :binary_id, autogenerate: true}

  schema "users" do
    field :first_name, :string
    field :last_name, :string

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
