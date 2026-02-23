# Script for populating the database. You can run it as:
#
#     mix run priv/repo/seeds.exs
#
# Inside the script, you can read and write to any of your
# repositories directly:
#
#     TurboOctoPancakes.Repo.insert!(%TurboOctoPancakes.SomeSchema{})
#
# We recommend using the bang functions (`insert!`, `update!`
# and so on) as they will fail if something goes wrong.

Code.require_file("priv/repo/seeds/users.exs")
Code.require_file("priv/repo/seeds/currencies.exs")
Code.require_file("priv/repo/seeds/products.exs")

defmodule Seeds do
  alias TurboOctoPancakes.Repo

  def run do
    IO.puts("=== Starting database seeding ===\n")

    init_context()
    |> seed_users()
    |> seed_currencies()
    |> seed_products()
    |> handle_result()
  end

  defp init_context do
    case Repo.query("SELECT 1") do
      {:ok, _} -> {:ok, %{}}
      {:error, reason} -> {:error, {:db_connection, reason}}
    end
  end

  defp seed_users({:error, _} = error), do: error

  defp seed_users({:ok, context}) do
    case Seeds.Users.run() do
      {:ok, info} ->
        IO.puts("")
        {:ok, Map.put(context, :users, info)}

      {:error, _} = error ->
        error
    end
  end
  defp seed_currencies({:error, _} = error), do: error

  defp seed_currencies({:ok, context}) do
    case Seeds.Currencies.run() do
      {:ok, info} ->
        IO.puts("")
        {:ok, Map.put(context, :currencies, info)}

      {:error, _} = error ->
        error
    end
  end
  defp seed_products({:error, _} = error), do: error

  defp seed_products({:ok, context}) do
    case Seeds.Products.run() do
      {:ok, info} ->
        IO.puts("")
        {:ok, Map.put(context, :products, info)}

      {:error, _} = error ->
        error
    end
  end


  defp handle_result({:ok, context}) do
    IO.puts("\n=== Seeding complete ===")
    IO.puts("  Users: #{context.users.total_inserted}")
    IO.puts("  Currencies: #{context.currencies.total_inserted}")
    IO.puts("  products: #{context.products.total_inserted}")
    :ok
  end

  defp handle_result({:error, reason}) do
    IO.puts("\n=== Seeding failed: #{inspect(reason)} ===")
    {:error, reason}
  end
end

Seeds.run()
