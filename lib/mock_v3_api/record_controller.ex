defmodule MockV3Api.RecordController do
  use Plug.Builder
  alias MockV3Api.HTTPClient
  alias Plug.Conn
  import Plug.Conn, only: [assign: 3, send_resp: 1, put_resp_content_type: 2, resp: 3, halt: 1, put_status: 2]

  def call(%Conn{assigns: %{file_name: {:error, :no_path}}} = conn, _) do
    conn
    |> put_status(500)
    |> assign(:error, "no path provided")
    |> send_response()
  end
  def call(%Conn{assigns: %{file_data: {:error, :enoent}}, path_params: %{"path" => path}} = conn, _) do
    path
    |> HTTPClient.get(conn.query_params)
    |> handle_response(conn)
    |> send_response()
  end
  def call(%Conn{assigns: %{file_data: {:ok, data}}} = conn, _) do
    conn
    |> assign(:result, :error)
    |> assign(:error, :file_already_recorded)
    |> assign(:file_data, data)
    |> send_response()
  end

  defp handle_response({:ok, %HTTPoison.Response{body: data, status_code: 200}}, %Conn{assigns: %{file_path: file_path}} = conn) do
    :ok = File.write(file_path, data)
    file_path
    |> File.write(data)
    |> assign_result(conn)
  end
  defp handle_response({:ok, %HTTPoison.Response{} = response}, conn) do
    {:error, %{message: :unexpected_response, response: %{response | headers: Enum.into(response.headers, %{})}}}
    |> assign_result(conn)
    |> put_status(500)
  end
  defp handle_response({:error, error}, conn) do
    {:error, %{message: :http_error, response: error}}
    |> assign_result(conn)
    |> put_status(500)
  end

  defp assign_result(:ok, %Conn{assigns: %{file_path: file_path}} = conn) do
    conn
    |> assign(:result, :ok)
    |> assign(:file_data, File.read!(file_path))
  end
  defp assign_result({:error, error}, %Conn{} = conn) do
    conn
    |> assign(:result, :error)
    |> assign(:error, error)
    |> assign(:file_data, nil)
  end

  defp send_response(conn) do
    %{conn | state: :set}
    |> put_resp_content_type("json")
    |> resp(200, conn.assigns)
    |> send_resp()
    |> halt()
  end
end
