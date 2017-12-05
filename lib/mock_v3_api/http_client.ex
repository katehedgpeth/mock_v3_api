defmodule MockV3Api.HTTPClient do
  require Logger
  alias Plug.Conn.Query

  def get([_ | _] = path, query_params) do
    request_path = build_url(path, query_params)

    Logger.debug("calling " <> request_path)

    HTTPoison.get(request_path)
  end

  defp build_url(path, query_params) do
    query_params
    |> Map.put("api_key", System.get_env("V3_API_KEY"))
    |> Query.encode()
    |> build_request_path(path)
  end

  defp build_request_path(query_params, path) do
    URI.to_string(%URI{
      scheme: "https",
      host: "dev.api.mbtace.com",
      path: Path.join(["/" | path]),
      query: query_params
    })
  end
end
