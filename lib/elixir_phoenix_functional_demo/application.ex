defmodule ElixirPhoenixFunctionalDemo.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      ElixirPhoenixFunctionalDemoWeb.Telemetry,
      ElixirPhoenixFunctionalDemo.Repo,
      {DNSCluster,
       query: Application.get_env(:elixir_phoenix_functional_demo, :dns_cluster_query) || :ignore},
      {Phoenix.PubSub, name: ElixirPhoenixFunctionalDemo.PubSub},
      # Start a worker by calling: ElixirPhoenixFunctionalDemo.Worker.start_link(arg)
      # {ElixirPhoenixFunctionalDemo.Worker, arg},
      # Start to serve requests, typically the last entry
      ElixirPhoenixFunctionalDemoWeb.Endpoint
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: ElixirPhoenixFunctionalDemo.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    ElixirPhoenixFunctionalDemoWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
