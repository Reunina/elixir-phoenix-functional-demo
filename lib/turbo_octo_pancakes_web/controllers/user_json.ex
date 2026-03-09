defmodule TurboOctoPancakesWeb.UserJSON do
  @moduledoc """
  JSON rendering for UserController responses.
  """

  def index(%{users: users}) do
    now = DateTime.utc_now()

    %{users: Enum.map(users, &user(&1, now))}
  end

  def error(%{message: message}) do
    %{error: %{message: message}}
  end

  defp user(%{products: %Ecto.Association.NotLoaded{}} = user, _now) do
    %{
      id: user.id,
      first_name: user.first_name,
      last_name: user.last_name,
      products: []
    }
  end

  defp user(
         %{id: id, first_name: first_name, last_name: last_name, products: products},
         now
       ) do
    active_products =
      products
      |> Enum.filter(&active_product?(&1, now))
      |> Enum.map(&product/1)

    %{
      id: id,
      first_name: first_name,
      last_name: last_name,
      products: active_products
    }
  end

  defp product(%{
         id: id,
         label: label,
         price: price,
         stock: stock,
         start_date: start_date,
         end_date: end_date,
         currency: currency
       }) do
    %{
      id: id,
      label: label,
      amount: price,
      stock: stock,
      currency: currency && currency.code,
      start_date: start_date,
      end_date: end_date
    }
  end

  defp active_product?(
         %{
           start_date: %DateTime{} = start_date,
           end_date: end_date
         },
         %DateTime{} = now
       ) do
    has_started? = DateTime.compare(start_date, now) in [:lt, :eq]

    not_finished? =
      is_nil(end_date) or
        (match?(%DateTime{}, end_date) and DateTime.compare(end_date, now) in [:gt, :eq])

    has_started? and not_finished?
  end
end
