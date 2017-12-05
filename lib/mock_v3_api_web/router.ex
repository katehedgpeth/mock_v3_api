defmodule MockV3ApiWeb.Router do
  use MockV3ApiWeb, :router

  pipeline :api do
    plug :accepts, ["html", "json"]
    plug :fetch_query_params
    plug FileReader
  end

  scope "/", MockV3ApiWeb do
    pipe_through :api

    get "/record/*path", RecordController, :index
    get "/*path", JsonController, :index
  end
end
