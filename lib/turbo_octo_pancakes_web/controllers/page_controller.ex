defmodule TurboOctoPancakesWeb.PageController do
  use TurboOctoPancakesWeb, :controller

  def home(conn, _params) do
    render(conn, :home)
  end
end
