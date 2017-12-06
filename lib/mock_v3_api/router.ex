defmodule MockV3Api.Router do
  use Plug.Router
  alias MockV3Api.{JsonController, RecordController}
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

  plug :verify_endpoint
  plug :fetch_query_params
  plug FileReader
  plug :match
  plug :dispatch

  get "/record/*path", to: RecordController
  get "/*path", to: JsonController

  def init(conn, _), do: []

  def verify_endpoint(%Conn{path_info: ["record", endpoint | _]} = conn, _) when endpoint in @endpoints, do: conn
  def verify_endpoint(%Conn{path_info: [endpoint | _]} = conn, _) when endpoint in @endpoints, do: conn
  def verify_endpoint(%Conn{path_info: path} = conn, _) do
    {:ok, resp} = Poison.encode(%{path: Path.join(["/" | path]), error: "not an endpoint"})
    conn
    |> Map.put(:state, :set)
    |> put_resp_content_type("json")
    |> Conn.send_resp(500, resp)
    |> halt()
  end
end
