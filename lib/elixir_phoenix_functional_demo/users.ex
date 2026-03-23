defmodule ElixirPhoenixFunctionalDemo.Users.Behaviour do
  @moduledoc """
  Behaviour for the Users context.
  Allows mocking in tests.
  """

  alias ElixirPhoenixFunctionalDemo.Users.User

  @callback list_users(opts :: map()) :: {:ok, [User.t()]} | {:error, term()}
end

defmodule ElixirPhoenixFunctionalDemo.Users do
  @moduledoc """
  The Users context.
  """

  import Ecto.Query

  alias ElixirPhoenixFunctionalDemo.Repo
  alias ElixirPhoenixFunctionalDemo.Users.User
  alias ElixirPhoenixFunctionalDemo.Users.Product

  @behaviour ElixirPhoenixFunctionalDemo.Users.Behaviour

  @impl true
  def list_users(opts \\ %{}) do
    users =
      %{}
      |> init(opts)
      |> apply_filters()
      |> order_by()
      |> repo_all()
      |> load_products()

    {:ok, users}
  rescue
    e -> {:error, e}
  end

  defp repo, do: Application.get_env(:elixir_phoenix_functional_demo, :repo, Repo)

  defp repo_all(ctx),
    do:
      ctx
      |> Map.get(:query)
      |> repo().all()

  defp load_products(users) do
    repo().preload(users, products: [:currency])
  end

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
        {:by_name, name}, acc_query ->
          filter_by_name(acc_query, name)

        {:has_active_product, flag}, acc_query ->
          filter_by_has_active_product(acc_query, flag)

        _, acc_query ->
          acc_query
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

  defp filter_by_has_active_product(query, true) do
    from u in query,
      join: p in Product,
      on:
        p.user_id == u.id and
          p.start_date <= fragment("now() AT TIME ZONE 'UTC'") and
          (is_nil(p.end_date) or p.end_date >= fragment("now() AT TIME ZONE 'UTC'")),
      distinct: u.id
  end

  defp filter_by_has_active_product(query, false) do
    active_product_user_ids_query =
      from p in Product,
        where:
          p.start_date <= fragment("now() AT TIME ZONE 'UTC'") and
            (is_nil(p.end_date) or p.end_date >= fragment("now() AT TIME ZONE 'UTC'")),
        select: p.user_id

    from u in query, where: u.id not in subquery(active_product_user_ids_query)
  end
end
