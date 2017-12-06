defmodule MockV3Api.JsonController do
  require Logger
  use Plug.Builder
  alias Plug.Conn
  alias MockV3Api.HTTPClient
  import Plug.Conn

  def call(%Conn{assigns: %{file_data: {:error, _}}, path_params: %{"path" => path}} = conn, _) do
    ["path not matched: ", get_request_path(conn)]
    |> Logger.warn()

    path
    |> HTTPClient.get(conn.query_params)
    |> handle_response(conn)
    |> send_response()
  end
  def call(%Conn{assigns: %{file_data: {:ok, data}, file_path: file_path}} = conn, _) do
    ["Path matched: ", "\n\s\srequest_path: ", get_request_path(conn), "\n\s\sjson_file: ", file_path]
    |> Logger.debug()

    conn
    |> assign(:data, data)
    |> send_response()
  end

  defp get_request_path(conn), do: Path.join(conn.request_path, conn.query_string)

  def handle_response({:ok, %HTTPoison.Response{body: data, status_code: status_code}}, conn) do
    conn
    |> assign(:data, data)
    |> put_status(status_code)
  end

  def handle_response({:error, error}, conn) do
    Logger.warn("HTTP error: #{inspect error}")

    conn
    |> assign(:data, %{error: error})
    |> put_status(500)
  end

  defp send_response(conn) do
    conn
    |> put_resp_content_type("json")
    |> resp(200, conn.assigns.data)
    |> send_resp()
  end
end
