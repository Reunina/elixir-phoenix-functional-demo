defmodule Seeds.Products do
  import Ecto.Query
  alias ElixirPhoenixFunctionalDemo.Repo
  alias ElixirPhoenixFunctionalDemo.Users.Currency
  alias ElixirPhoenixFunctionalDemo.Users.Product
  alias ElixirPhoenixFunctionalDemo.Users.User

  @batch_size 5_000
  @min_amount 30
  @max_amount 5_000
  @date_range_days 365
  @today Date.utc_today()
  @range_product_per_user 0..3

  def run do
    {:ok, %{}}
    |> load_user_ids()
    |> load_currencies_codes()
    |> generate_products_data()
    |> insert_products()
    |> handle_result()
  end

  defp load_user_ids({:error, _} = error), do: error

  defp load_user_ids({:ok, context}) do
    user_ids = Repo.all(from u in User, select: u.id)
    IO.puts("Generating products for #{length(user_ids)} users...")
    {:ok, Map.put(context, :user_ids, user_ids)}
  end

  defp load_currencies_codes({:error, _} = error), do: error

  defp load_currencies_codes({:ok, context}) do
    currency_codes = Repo.all(from c in Currency, select: c.code)
    {:ok, Map.put(context, :currency_codes, currency_codes)}
  end

  defp generate_products_data({:error, _} = error), do: error

  defp generate_products_data(
         {:ok,
          %{
            user_ids: user_ids,
            currency_codes: currency_codes
          } = context}
       ) do
    {:ok,
     Map.put(
       context,
       :products_stream,
       user_ids
       |> Stream.flat_map(&generate_products_for_user(&1))
       |> Stream.map(fn product ->
         currency_code = Enum.random(currency_codes)
         Map.put(product, :currency_code, currency_code)
       end)
     )}
  end

  defp generate_products_for_user(user_id) do
    case Enum.random(@range_product_per_user) do
      0 ->
        []

      num_products ->
        1..num_products
        |> Enum.map(fn index ->
          start_date = random_date(@today, -@date_range_days, @date_range_days)
          end_date = maybe_generate_end_date(index, start_date)

          %{
            user_id: user_id,
            price: Enum.random(@min_amount..@max_amount),
            stock: Enum.random(0..5),
            label:
              to_string(
                (Enum.to_list(?A..?Z) ++ Enum.to_list(?a..?z) ++ Enum.to_list(?0..?9))
                |> Enum.take_random(8)
              ),
            start_date: date_to_utc_datetime(start_date),
            end_date: date_to_utc_datetime(end_date)
          }
        end)
    end
  end

  defp insert_products({:error, _} = error), do: error

  defp insert_products({:ok, %{products_stream: products_stream} = context}) do
    case Repo.transaction(fn ->
           products_stream
           |> Stream.chunk_every(@batch_size)
           |> Enum.reduce(0, fn batch, acc ->
             {count, _} = Repo.insert_all(Product, batch, on_conflict: :nothing)
             IO.puts("  Inserted batch: #{count} products")
             acc + count
           end)
         end) do
      {:ok, total_inserted} ->
        {:ok, Map.put(context, :total_inserted, total_inserted)}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp date_to_utc_datetime(nil), do: nil

  defp date_to_utc_datetime(%Date{} = date) do
    DateTime.new!(date, ~T[00:00:00], "Etc/UTC")
  end

  defp maybe_generate_end_date(1, start_date) do
    if Enum.random([true, false]) do
      nil
    else
      random_date(start_date, 1, @date_range_days)
    end
  end

  defp maybe_generate_end_date(_index, start_date) do
    random_date(start_date, 1, @date_range_days)
  end

  defp random_date(base_date, min_offset, max_offset) do
    offset = Enum.random(min_offset..max_offset)
    Date.add(base_date, offset)
  end

  defp handle_result({:ok, %{total_inserted: total_inserted}}) do
    IO.puts("Seeded #{total_inserted} products")
    {:ok, %{total_inserted: total_inserted}}
  end

  defp handle_result({:error, reason}) do
    IO.puts("Failed to seed products: #{inspect(reason)}")
    {:error, reason}
  end
end
