defmodule MockV3ApiWeb.JsonController do
  require Logger
  use MockV3ApiWeb, :controller
  alias Plug.Conn
  alias Plug.Conn.Query
  alias MockV3Api.HTTPClient

  def index(%Conn{assigns: %{file_data: {:error, _}}} = conn, %{"path" => path}) do
    IO.inspect conn
    ["path not matched: ", get_request_path(conn)]
    |> Logger.warn()

    path
    |> HTTPClient.get(conn.query_params)
    |> send_response(conn)
  end
  def index(%Conn{assigns: %{file_data: {:ok, data}, file_path: file_path}} = conn, _) do
    ["Path matched: ", "\n\s\srequest_path: ", get_request_path(conn), "\n\s\sjson_file: ", file_path]
    |> Logger.debug()
    json(conn, data)
  end

  defp send_response({:ok, %HTTPoison.Response{body: data, status_code: status_code}}, conn) do
    conn
    |> put_status(status_code)
    |> json(data)
  end
  defp send_response({:error, error}, conn) do
    Logger.warn("HTTP error: #{inspect error}")
    conn
    |> put_status(500)
    |> json(%{error: error})
  end

  defp get_request_path(conn), do: Path.join(conn.request_path, conn.query_string)
end
