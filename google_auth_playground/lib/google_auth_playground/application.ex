defmodule GoogleAuthPlayground.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @impl true
  def start(_type, _args) do
    children = [
      # Start the Telemetry supervisor
      GoogleAuthPlaygroundWeb.Telemetry,
      # Start the Ecto repository
      GoogleAuthPlayground.Repo,
      {Oban, Application.fetch_env!(:google_auth_playground, Oban)},
      # Start the PubSub system
      {Phoenix.PubSub, name: GoogleAuthPlayground.PubSub},
      # Start Finch
      {Finch, name: GoogleAuthPlayground.Finch},
      # Start the Endpoint (http/https)
      GoogleAuthPlaygroundWeb.Endpoint
      # Start a worker by calling: GoogleAuthPlayground.Worker.start_link(arg)
      # {GoogleAuthPlayground.Worker, arg}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: GoogleAuthPlayground.Supervisor]
    Supervisor.start_link(children, opts)
  end

  # Tell Phoenix to update the endpoint configuration
  # whenever the application is updated.
  @impl true
  def config_change(changed, _new, removed) do
    GoogleAuthPlaygroundWeb.Endpoint.config_change(changed, removed)
    :ok
  end
end
