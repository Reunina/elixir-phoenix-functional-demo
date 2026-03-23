defmodule ElixirPhoenixFunctionalDemoWeb.RouterTest do
  use ExUnit.Case, async: true

  alias ElixirPhoenixFunctionalDemoWeb.Router

  test "users index route uses the :api pipeline" do
    route_meta =
      Phoenix.Router.route_info(Router, "GET", "/users", "")

    assert route_meta != :error,
           "Expected to find a GET /users route in the router, but none was found"

    assert :api in route_meta.pipe_through,
           "GET /users route is expected to pipe through :api pipeline"
  end
end
