defmodule Mix.Tasks.Xtra do
  use Mix.Task

  @shortdoc "Transforms templates"

  @moduledoc """

  #  Transform EEx templates in the context of the `Extractly` module.


    If a template is indicated than it is run in the context of the `Extractly` module which is
    passed in as variable `xtra`. And the output is written to a file named like the template without
    the `.eex` extension.

    This behavior can be changed via command line switches.

    Without an input template provided, the task is implying that `README.md.eex` was passed in.

    The `Extractly` module is available inside the templates but is also passed in as variable `xtra` for
    the convenience of the templates' authors.

    E.g. use the following template to extract some documentation from a module `M`.

        Some text
        <%= xtra.function_doc(M, :shiny_function/2) %>
        More text
  """

  @impl true
  def run(_args) do
    IO.puts :stderr, "Coming soon"
  end

end
