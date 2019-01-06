defmodule Mix.Tasks.Xtra do
  use Mix.Task

  @shortdoc "Transforms templates"

  @moduledoc """

  ##  Mix task to Transform EEx templates in the context of the `Extractly` module.


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

  @strict [
    version: :boolean,
    help: :boolean,
    output: :string
  ]

  @impl true
  def run(args) do
    OptionParser.parse(args, strict: @strict)
    |> _mappify_options()
    |> _run()
  end

  defp _croak(message, code \\ 1) do
    IO.puts :stderr, message
    exit code
  end
  defp _mappify_options({options, args, errors}),
    do: {options |> Enum.into(%{}), args, errors}

  @help_text """
  mix xtra

  convert Eex template file to output with a shiny CLI and __Extra__ context from the `Extractly` module

  For more detailed information use

        mix xtra.help
  """
  defp _process(options, template)
  defp _process(%{help: true}, _), do: IO.puts(@help_text)
  defp _process(%{version: true}, _), do: IO.puts(Extractly.version)
  defp _process(options, template), do:
    if File.exists?(template),
      do: _process_template(options, template),
      else: _croak("Template #{template} does not exist", 2)

  defp _process_template(options, template) do
    output_fn = Map.get(options, :output, String.replace(template, ~r{\.eex\z}, ""))
    output = EEx.eval_file(template, [xtra: Extractly])
    case File.write(output_fn, output) do
      :ok -> :ok
      {:error, posix_reason} = x -> IO.puts :stderr, "Cannot write to #{output_fn}, reason: #{:file.format_error(posix_reason)}"
                                    x
    end
  end

  defp _run(parsed)
  defp _run({options, [], []}), do: _process(options, "README.md.eex")
  defp _run({options, [template | args], []}) do
    unless Enum.empty?(args) do
      IO.puts :stderr, "WARNING: Spourious templates #{inspect args} are ignored"
    end
    _process(options, template)
  end
  defp _run({_, _, errors}), do:
    _croak "ERROR: Illegal arguments: #{inspect(errors)}\n\nTry `mix xtra.help` for, well, some help"

end
