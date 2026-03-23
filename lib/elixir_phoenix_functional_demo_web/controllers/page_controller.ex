defmodule ElixirPhoenixFunctionalDemoWeb.PageController do
  use ElixirPhoenixFunctionalDemoWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
