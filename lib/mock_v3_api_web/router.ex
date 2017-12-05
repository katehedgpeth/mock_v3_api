defmodule MockV3ApiWeb.Router do
  use MockV3ApiWeb, :router
  alias Plug.Conn

  @endpoints [
    "vehicles",
    "trips",
    "stops",
    "shapes",
    "schedules",
    "routes",
    "predictions",
    "facilities",
    "alerts",
  ]

  pipeline :api do
    plug :accepts, ["html", "json"]
    plug :verify_endpoint
    plug :fetch_query_params
    plug FileReader
  end

  scope "/", MockV3ApiWeb do
    pipe_through :api

    get "/record/*path", RecordController, :index
    get "/*path", JsonController, :index
  end

  def verify_endpoint(%Conn{path_info: ["record", endpoint | _]} = conn, _) when endpoint in @endpoints, do: conn
  def verify_endpoint(%Conn{path_info: [endpoint | _]} = conn, _) when endpoint in @endpoints, do: conn
  def verify_endpoint(%Conn{path_info: path} = conn, _) do
    {:ok, resp} = Poison.encode(%{path: Path.join(["/" | path]), error: "not an endpoint"})
    conn
    |> put_resp_content_type("json")
    |> Conn.send_resp(500, resp)
    |> halt()
  end
end
