defmodule FileReader do
  alias Plug.Conn

  @json_folder Application.app_dir(:mock_v3_api, "priv/json")

  def init(_), do: []

  def call(%Conn{} = conn, opts) do
    IO.inspect opts, label: "opts"
    conn
    |> get_request_path()
    |> get_file_path(conn)
    |> do_call(conn)
  end

  defp do_call(file_path, %Conn{} = conn) do
    conn
    |> Conn.assign(:file_data, File.read(file_path))
    |> Conn.assign(:file_path, file_path)
  end

  defp get_request_path(%Conn{path_info: ["record" | path]}), do: path
  defp get_request_path(%Conn{path_info: path}), do: path

  defp get_file_path([], _conn), do: {:error, :no_path}
  defp get_file_path(["record"], _conn), do: {:error, :no_path}
  defp get_file_path(path, conn) when is_list(path) do
    path
    |> get_folder()
    |> do_get_file_path(conn, path)
  end

  defp do_get_file_path(folder, conn, [file_name]), do: do_get_file_name(folder, conn, file_name)
  defp do_get_file_path(folder, conn, [_ | file_name]), do: do_get_file_name(folder, conn, file_name)

  defp do_get_file_name(folder, %Conn{query_params: query_params}, file_name) do
    Path.join(folder, [file_name, Enum.reduce(query_params, "", &build_query_params/2), ".json"])
  end

  defp get_folder(path_info) do
    folder = folder_name(path_info)
             |> IO.inspect()
    path = Path.join(@json_folder, folder)
    :ok = File.mkdir_p(path)
    path
  end

  defp folder_name([_]), do: ""
  defp folder_name([folder_name | _]), do: folder_name

  defp build_query_params({"api_key", _}, acc), do: acc
  defp build_query_params({"page", params}, acc) when is_map(params) do
    params
    |> Enum.map(fn {key, val} -> {"page-" <> key, val} end)
    |> Enum.reduce(acc, &build_query_params/2)
  end
  defp build_query_params({"filter", params}, acc) when is_map(params) do
    params
    |> Enum.map(fn {key, val} -> {"filter-" <> key, val} end)
    |> Enum.reduce(acc, &build_query_params/2)
  end
  defp build_query_params({key, val}, acc) when is_binary(val), do: do_build_query_params(acc, key, val)

  defp do_build_query_params(acc, "filter-date", _), do: acc
  defp do_build_query_params(acc, "as", _), do: acc
  defp do_build_query_params(acc, key, val) do
    IO.iodata_to_binary([acc, "__", key, "--", val])
  end
end
