defmodule TurboOctoPancakes.Repo do
  use Ecto.Repo,
    otp_app: :turbo_octo_pancakes,
    adapter: Ecto.Adapters.Postgres
end
