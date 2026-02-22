defmodule TurboOctoPancakes.Users.Behaviour do
  @moduledoc """
  Behaviour for the Users context.
  Allows mocking in tests.
  """

  alias TurboOctoPancakes.Users.User

  @callback list_users(opts :: map()) :: {:ok, [User.t()]} | {:error, term()}
end

defmodule TurboOctoPancakes.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query

  alias TurboOctoPancakes.Repo
  alias TurboOctoPancakes.Users.User

  @behaviour TurboOctoPancakes.Users.Behaviour

  @impl true
  def list_users(opts \\ %{}) do
    users =
      %{}
      |> init(opts)
      |> apply_filters()
      |> order_by()
      |> repo_all()

    {:ok, users}
  rescue
    e -> {:error, e}
  end

  defp repo, do: Application.get_env(:turbo_octo_pancakes, :repo, Repo)

  defp repo_all(ctx),
    do:
      ctx
      |> Map.get(:query)
      |> repo().all()

  defp init(ctx, opts) do
    ctx
    |> Map.put(:query, User)
    |> Map.put(:order, Map.get(opts, :order))
    |> Map.put(:filter, Map.get(opts, :filter, %{}))
  end

  defp order_by(%{query: query, order: :by_name} = ctx),
    do:
      ctx
      |> Map.merge(%{
        query:
          from(u in query,
            order_by: fragment("lower(? || ' ' || ?)", u.first_name, u.last_name)
          )
      })

  defp order_by(ctx), do: ctx

  defp apply_filters(%{query: query} = ctx) do
    filters = Map.get(ctx, :filter, %{})

    updated_query =
      Enum.reduce(filters, query, fn
        {:by_name, name}, acc_query -> filter_by_name(acc_query, name)
        _, acc_query -> acc_query
      end)

    Map.put(ctx, :query, updated_query)
  end

  defp filter_by_name(query, name) do
    search_term = "%#{name}%"

    from u in query,
      where:
        ilike(u.first_name, ^search_term) or
          ilike(u.last_name, ^search_term) or
          ilike(fragment("? || ' ' || ?", u.first_name, u.last_name), ^search_term)
  end
end
