defmodule Seeds.Users do
  alias ElixirPhoenixFunctionalDemo.Repo
  alias ElixirPhoenixFunctionalDemo.Users.User

  @target_users 20_000
  @batch_size 5_000

  @names_path "priv/repo/data/names.txt"

  def run do
    IO.puts("Generating #{@target_users} users...")

    {:ok, %{}}
    |> generate_users_data()
    |> insert_users()
    |> handle_result()
  end

  defp generate_users_data({:error, _} = error), do: error

  defp generate_users_data({:ok, _}) do
    {:ok, %{}}
    |> retrieve_names_list()
    |> generate_users()
  end

  defp generate_users({:error, _} = error), do: error

  defp generate_users({:ok, context}) do
    names = Map.get(context, :names, ["Jane", "john"])

    users_data =
      Stream.zip(Stream.cycle(names), Stream.cycle(Enum.shuffle(names)))
      |> Stream.take(@target_users)
      |> Stream.map(fn {first_name, last_name} ->
        %{
          first_name: first_name,
          last_name: last_name
        }
      end)

    {:ok, Map.put(context, :users_data, users_data)}
  end

  defp insert_users({:error, _} = error), do: error

  defp insert_users({:ok, %{users_data: users_data} = context}) do
    case Repo.transaction(fn ->
           users_data
           |> Stream.chunk_every(@batch_size)
           |> Enum.reduce([], fn batch, acc ->
             {count, returned_ids} =
               Repo.insert_all(
                 User,
                 batch,
                 on_conflict: :nothing,
                 returning: [:id]
               )

             IO.puts("  Inserted batch: #{count} users")
             acc ++ Enum.map(returned_ids, & &1.id)
           end)
         end) do
      {:ok, inserted_ids} ->
        {:ok,
         context
         |> Map.put(:total_inserted, length(inserted_ids))}

      {:error, reason} ->
        {:error, reason}
    end
  end

  defp handle_result({:ok, context}) do
    IO.puts("Seeded #{Map.get(context, :total_inserted)} users")
    {:ok, context}
  end

  defp handle_result({:error, reason}) do
    IO.puts("Failed to seed users: #{inspect(reason)}")
    {:error, reason}
  end

  # reading names from data file
  defp retrieve_names_list({:ok, context}) do
    case File.read(@names_path) do
      {:ok, content} -> {:ok, Map.put(context, :content, content)}
      {:error, reason} -> {:error, reason}
    end
    |> parse_names()
  end

  defp parse_names({:error, _} = error), do: error

  defp parse_names({:ok, %{content: content} = context}) do
    names =
      content
      |> String.split("\n", trim: true)
      |> Enum.map(fn line -> String.trim(line) end)

    {:ok, Map.put(context, :names, names)}
  end
end
