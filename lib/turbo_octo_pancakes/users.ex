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

  defp init(ctx, opt) do
    ctx
    |> Map.put(:query, User)
    |> Map.put(:order, opt |> Map.get(:order))
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
end
