defmodule Seeds.Currencies do
  alias TurboOctoPancakes.Repo
  alias TurboOctoPancakes.Users.Currency

  @csv_path "priv/repo/data/currencies.csv"

  def run do
    IO.puts("Seeding currencies...")

    retrieve_currencies()
    |> insert_currencies()
    |> handle_result()
  end

  defp retrieve_currencies(),
    do:
      {:ok, %{}}
      |> read_csv()
      |> parse_csv()

  defp read_csv({:error, _} = error), do: error

  defp read_csv({:ok, context}) do
    case File.read(@csv_path) do
      {:ok, content} -> {:ok, Map.put(context, :content, content)}
      {:error, reason} -> {:error, reason}
    end
  end

  defp parse_csv({:error, _} = error), do: error

  defp parse_csv({:ok, %{content: content} = context}) do
    currencies_data =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line ->
        [code, decimal | _] = String.split(line, ";")

        %{
          code: code,
          decimal: String.to_integer(decimal)
        }
      end)

    {:ok, Map.put(context, :currencies_data, currencies_data)}
  end

  defp insert_currencies({:error, _} = error), do: error

  defp insert_currencies({:ok, %{currencies_data: data} = context}) do
    {count, _} = Repo.insert_all(Currency, data, on_conflict: :nothing)
    {:ok, Map.put(context, :count, count)}
  end

  defp handle_result({:ok, %{count: count}}) do
    IO.puts("Seeded #{count} currencies")
    {:ok, %{total_inserted: count}}
  end

  defp handle_result({:error, reason}) do
    IO.puts("Failed to seed currencies: #{inspect(reason)}")
    {:error, reason}
  end
end
