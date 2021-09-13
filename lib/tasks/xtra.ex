defmodule Mix.Tasks.Xtra do
  use Mix.Task

  @shortdoc "Transforms templates"

  @moduledoc """

  ##  Mix task to Transform EEx templates in the context of the `Extractly` module.

    This tool serves two purposes.

    1. A simple CLI to basicly `EEx.eval_file/2`

    1. Access to the `Extractly` module (available as binding `xtra` too)

    1. Access to the name of the rendered template with the `template` binding

    The `Extractly` module gives easy access to Elixir metainformation of the application using
    the `extractly` package, notably, _module_  and _function_ documentation.

    This is BTW the raison d'être of this package, simple creation of a `README.md` file with very simple
    access to the projects hex documentation.

    Thusly hexdoc and Github will always be synchronized.

    To see that in action just look at the [`README.md.eex`](README.md.eex) file of this package and compare
    with what you are reading here.


    Example Template:

        Some text
        <%= xtra.functiondoc("M.shiny_function/2") %>
        <%= xtra.moduledoc("String") %>

        More text
  """

  @strict [
    help: :boolean,
    output: :string,
    quiet: :boolean,
    verbose: :boolean,
    version: :boolean,
  ]

  @aliases [
    h: :help,
    q: :quiet,
    v: :version,
    V: :verbose
  ]

  @impl true
  def run(args) do
    Extractly.Messages.Agent.start_link
    OptionParser.parse(args, strict: @strict, aliases: @aliases)
    |> _mappify_options()
    |> _run()
    |> _output()
  end

  defp _mappify_options({options, args, errors}),
    do: {options |> Enum.into(%{}), args, errors}

  # run returns the options unless an error occurred
  defp _output(opts_or_error)
  defp _output(opts) when is_map(opts) do
    opts
    |> _severity()
    |> Extractly.Messages.messages
    |> Enum.each(&_output_message/1)
  end
  defp _output(_), do: nil

  defp _output_message({status, message}), do: IO.puts(:stderr, "*#{status}* -- #{message}")

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
      else: _puts_err("Template #{template} does not exist", options)

  defp _process_template(options, template) do
    try do
      Mix.Task.run("compile")
    rescue
      UndefinedFunctionError -> nil
    end
    output_fn = Map.get(options, :output, String.replace(template, ~r{\.eex\z}, ""))
    output = EEx.eval_file(template, [xtra: Extractly.Xtra, template: template, options: options])
    case File.write(output_fn, output) do
      :ok -> options
      {:error, posix_reason} = x -> _puts_err("Cannot write to #{output_fn}, reason: #{:file.format_error(posix_reason)}", options)
                                    x
    end
  end

  defp _run(parsed)
  defp _run({options, [], []}), do: _process(options, "README.md.eex")
  defp _run({options, [template | args], []}) do
    unless Enum.empty?(args) do
      _puts_err("WARNING: Spourious templates #{inspect args} are ignored", options)
    end
    _process(options, template)
  end
  defp _run({options, _, errors}), do:
    _puts_err("ERROR: Illegal arguments: #{inspect(errors)}\n\nTry `mix xtra.help` for, well, some help", options)

  defp _puts_err(message, options)
  defp _puts_err(_, %{quiet: true}), do: nil
  defp _puts_err(message, _), do: IO.puts(:stderr, message)

  defp _severity(opts)
  defp _severity(%{verbose: true}), do: :debug
  defp _severity(%{quiet: true}), do: :error
  defp _severity(_), do: :info

end
