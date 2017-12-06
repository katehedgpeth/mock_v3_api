defmodule MockV3Api.Application do
  use Application

  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  def start(_type, _args) do
    # Define workers and child supervisors to be supervised
    config = Application.get_env(:mock_v3_api, MockV3Api.Endpoint)
    children = [
      # Start the endpoint when the application starts
      # supervisor(MockV3ApiWeb.Endpoint, []),
      Plug.Adapters.Cowboy.child_spec(:http, MockV3Api.Endpoint, [], [port: 8080])
      # Start your own worker by calling: MockV3Api.Worker.start_link(arg1, arg2, arg3)
      # worker(MockV3Api.Worker, [arg1, arg2, arg3]),
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: MockV3Api.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
