defmodule MockV3ApiWeb.RecordController do
  use MockV3ApiWeb, :controller
  alias MockV3Api.HTTPClient
  alias Plug.Conn

  def index(%Conn{assigns: %{file_name: {:error, :no_path}}} = conn, _) do
    json(conn, %{error: "no path provided"})
  end
  def index(%Conn{assigns: %{file_data: {:error, :enoent}, file_path: file_path}} = conn, %{"path" => path}) do
    IO.inspect path, label: "path"
    path
    |> HTTPClient.get(conn.query_params)
    |> handle_response(conn)
  end
  def index(%Conn{assigns: %{file_data: {:ok, data}}} = conn, _) do
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
    |> send_response()
  end
  defp handle_response({:ok, %HTTPoison.Response{} = response}, conn) do
    {:error, %{message: :unexpected_response, response: %{response | headers: Enum.into(response.headers, %{})}}}
    |> assign_result(conn)
    |> send_response()
  end
  defp handle_response({:error, error}, conn) do
    {:error, %{message: :http_error, response: error}}
    |> assign_result(conn)
    |> send_response()
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

  defp send_response(conn), do: json(conn, conn.assigns)
end
