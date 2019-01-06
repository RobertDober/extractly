defmodule Mix.Tasks.Xtra.Help do
  use Mix.Task

  @shortdoc "Explains availabe xtra subtasks"

  @moduledoc """
  ### Usage:
  
      mix xtra [options]... [template]

  #### Options:

      --help     Prints short help information to stdout and exits.
      --version  Prints the current version to stdout and exits.
      --verbose  Prints additional output to stderr

      --output filename
                The name of the file the rendered template is written to, defaults to the templates'
                name, without the suffix `.eex`

  #### Argument:

      template, filename of the `EEx` template to use, defaults to `"README.md.eex"`

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
