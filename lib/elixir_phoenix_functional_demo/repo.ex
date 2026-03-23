defmodule ElixirPhoenixFunctionalDemo.Repo do
  use Ecto.Repo,
    otp_app: :elixir_phoenix_functional_demo,
    adapter: Ecto.Adapters.Postgres
end
