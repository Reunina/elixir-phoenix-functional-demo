defmodule TurboOctoPancakesWeb.Router do
  use TurboOctoPancakesWeb, :router

  pipeline :browser do
    plug :accepts, ["html"]
    plug :fetch_session
    plug :fetch_live_flash
    plug :put_root_layout, html: {TurboOctoPancakesWeb.Layouts, :root}
    plug :protect_from_forgery
    plug :put_secure_browser_headers
  end

  pipeline :api do
    plug :accepts, ["json"]
  end

  # No CSRF – Swagger UI loads JS/CSS from CDN; protect_from_forgery would block those requests
  pipeline :swagger_ui do
    plug :accepts, ["html"]
  end

  # Swagger UI – serve interactive API docs at /swagger
  scope "/swagger" do
    pipe_through :swagger_ui

    forward "/", PhoenixSwagger.Plug.SwaggerUI,
      otp_app: :turbo_octo_pancakes,
      swagger_file: "swagger.json"
  end

  scope "/", TurboOctoPancakesWeb do
    pipe_through :browser

    get "/", PageController, :home
  end

  scope "/users", TurboOctoPancakesWeb do
    pipe_through :api

    get "/", UserController, :index
    post "/invite-users", UserController, :invite_users
  end

  # Other scopes may use custom stacks.
  # scope "/api", TurboOctoPancakesWeb do
  #   pipe_through :api
  # end

  # Enable LiveDashboard and Swoosh mailbox preview in development
  if Application.compile_env(:turbo_octo_pancakes, :dev_routes) do
    # If you want to use the LiveDashboard in production, you should put
    # it behind authentication and allow only admins to access it.
    # If your application does not have an admins-only section yet,
    # you can use Plug.BasicAuth to set up some basic authentication
    # as long as you are also using SSL (which you should anyway).
    import Phoenix.LiveDashboard.Router

    scope "/dev" do
      pipe_through :browser

      live_dashboard "/dashboard", metrics: TurboOctoPancakesWeb.Telemetry
      forward "/mailbox", Plug.Swoosh.MailboxPreview
    end
  end

  def swagger_info do
    %{
      info: %{
        version: "1.0",
        title: "Turbo Octo Pancakes API"
      },
      tags: [
        %{name: "Users", description: "List and filter users"}
      ]
    }
  end
end
