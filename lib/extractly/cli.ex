defmodule Extractly.Cli do
  
  @moduledoc """
  Exposes the mix task as an escript for usage on non mix projects
  """
  @doc "entry to the CLI, proxies to the mix task `mix xtra`"
  def main(argv) do
    Mix.Tasks.Xtra.run(argv)
  end
end
