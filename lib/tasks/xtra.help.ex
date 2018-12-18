defmodule Mix.Tasks.Xtra.Help do
  use Mix.Task

  @shortdoc "Explains availabe xtra subtasks"

  @moduledoc """
      mix xtra.help documents available subtasks
  """

  @help """
  The following xtra.* tasks are available


    * xtra


  """

  @impl true
  def run(_args) do
    IO.puts :stderr, @help
  end
  
end
