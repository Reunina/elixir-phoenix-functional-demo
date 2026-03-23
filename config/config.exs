# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :elixir_phoenix_functional_demo,
  ecto_repos: [ElixirPhoenixFunctionalDemo.Repo],
  generators: [timestamp_type: :utc_datetime]

# Configure the endpoint
config :elixir_phoenix_functional_demo, ElixirPhoenixFunctionalDemoWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: ElixirPhoenixFunctionalDemoWeb.ErrorHTML, json: ElixirPhoenixFunctionalDemoWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: ElixirPhoenixFunctionalDemo.PubSub,
  live_view: [signing_salt: "RhYTGlHi"]

# Configure the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :elixir_phoenix_functional_demo, ElixirPhoenixFunctionalDemo.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.25.4",
  elixir_phoenix_functional_demo: [
    args:
      ~w(js/app.js --bundle --target=es2022 --outdir=../priv/static/assets/js --external:/fonts/* --external:/images/* --alias:@=.),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => [Path.expand("../deps", __DIR__), Mix.Project.build_path()]}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "4.1.12",
  elixir_phoenix_functional_demo: [
    args: ~w(
      --input=assets/css/app.css
      --output=priv/static/assets/css/app.css
    ),
    cd: Path.expand("..", __DIR__)
  ]

# Configure Elixir's Logger
config :logger, :default_formatter,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Phoenix Swagger – generate priv/static/swagger.json from router and controller specs
config :elixir_phoenix_functional_demo, :phoenix_swagger,
  swagger_files: %{
    "priv/static/swagger.json" => [
      router: ElixirPhoenixFunctionalDemoWeb.Router,
      endpoint: ElixirPhoenixFunctionalDemoWeb.Endpoint
    ]
  }

config :phoenix_swagger, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
