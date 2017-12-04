defmodule MockV3ApiWeb.Router do
  use MockV3ApiWeb, :router

  pipeline :api do
    plug :accepts, ["json"]
  end

  scope "/api", MockV3ApiWeb do
    pipe_through :api
  end
end
