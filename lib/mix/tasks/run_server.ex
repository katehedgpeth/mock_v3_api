defmodule Mix.Tasks.MockV3Api.RunServer do
  use Mix.Task

  def run(_) do
    Mix.Tasks.Phx.Server.run(["--no-halt"])
  end
end
