  defmodule Extractly do
  alias Extractly.DoNotEdit

  import Extractly.Helpers

  @moduledoc """
    Provide easy access to information inside the templates rendered by `mix xtra`
  """

  @doc """
    Emits a comment including a message not to edit the created file, as it will be recreated from this template.

    It is a convenience to include this into your templates as follows

            <%= xtra.do_not_edit_warning %>

    or I18n'ed

            <%= xtra.do_not_edit_warning, lang: :fr %>

    If you are not generating html or markdown the comment can be parametrized

            <%= xtra.do_not_edit_warning, comment_start: "-- ", comment_end: "" %>

    If you want to include the name of the source template use `template: template` option, so
    a call may be as complex as:

            <%= xtra.do_not_edit_warning, comment_start: "-- ", comment_end: "", template: template, lang: :it %>

  """
  def do_not_edit_warning(opts \\ []), do: DoNotEdit.warning(opts)

  @doc ~S"""
    Returns docstring of a function
    Ex:

        iex(1)> {:ok, lines} = Extractly.functiondoc("Extractly.moduledoc/2") |> hd()
        ...(1)> lines |> String.split("\n") |> Enum.take(3)
        ["  Returns docstring of a module", "", "  E.g. verbatim"]

    We can also pass a list of functions to get their docs concatenated

        iex(2)> [{:ok, moduledoc}, {:error, message}] = Extractly.functiondoc(["Extractly.moduledoc/2", "Extactly.functiondoc/2"])
        ...(2)> moduledoc |> String.split("\n") |> Enum.take(4)
        [ "  Returns docstring of a module",
          "  E.g. verbatim",
          "",
          "      Extractly.moduledoc(\"Extractly\")"]
        ...(2)> message
        "Function doc for function Extactly.functiondoc/2 not found"

    If all the functions are in the same module the following form can be used

        iex(3)> [{:ok, out}, _] = Extractly.functiondoc(["moduledoc/2", "functiondoc/2"], module: "Extractly")
        ...(3)> String.split(out, "\n") |> hd()
        "  Returns docstring of a module"

    However it is convenient to add a markdown headline before each functiondoc, especially in these cases,
    it can be done by indicating the `headline: level` option

        iex(4)> [{:ok, moduledoc}, {:ok, functiondoc}] = Extractly.functiondoc(["moduledoc/2", "functiondoc/2"], module: "Extractly", headline: 2)
        ...(4)> moduledoc |> String.split("\n") |> Enum.take(3)
        [ "## Extractly.moduledoc/2",
          "",
          "  Returns docstring of a module"]
        ...(4)> functiondoc |> String.split("\n") |> Enum.take(3)
        [ "## Extractly.functiondoc/2",
          "",
          "  Returns docstring of a function"]

    Often times we are interested by **all** public functiondocs...

        iex(5)> [{:ok, out}|_] = Extractly.functiondoc(:all, module: "Extractly", headline: 2)
        ...(5)> String.split(out, "\n") |> Enum.take(3)
        [ "## Extractly.do_not_edit_warning/1",
          "",
          "  Emits a comment including a message not to edit the created file, as it will be recreated from this template."]

    We can specify a language to wrap indented code blocks into ` ```elixir\n...\n``` `

    Here is an example

        iex(6)> [ok: doc] = Extractly.functiondoc("Extractly.functiondoc/2", wrap_code_blocks: "elixir")
        ...(6)> doc |> String.split("\n") |> Enum.take(10)
        [ "  Returns docstring of a function",
          "  Ex:",
          "",
          "```elixir",
          "      iex(1)> {:ok, lines} = Extractly.functiondoc(\"Extractly.moduledoc/2\") |> hd()",
          "      ...(1)> lines |> String.split(\"\\n\") |> Enum.take(3)",
          "      [\"  Returns docstring of a module\", \"\", \"  E.g. verbatim\"]",
          "```",
          "",
          "  We can also pass a list of functions to get their docs concatenated"]

  """
  def functiondoc(name, opts \\ [])

  def functiondoc(:all, opts) do
    case Keyword.get(opts, :module) do
      nil -> [{:error, "No module given for `functiondoc(:all, ...)`"}]
      module_name -> _all_functiondocs(module_name, opts)
    end
  end

  def functiondoc(names, opts) when is_list(names) do
    prefix =
      case Keyword.get(opts, :module) do
        nil -> ""
        module_name -> "#{module_name}."
      end

    names
    |> Enum.flat_map(&functiondoc("#{prefix}#{&1}", opts))
    |> Enum.map(fn {status, result} -> {status, _postprocess(result, opts)} end)
  end

  def functiondoc(name, opts) when is_binary(name) do
    headline = fdoc_headline(name, opts)

    case _functiondoc(name) do
      nil -> [{:error, "Function doc for function #{name} not found"}]
      doc -> [{:ok, headline <> (doc |> _postprocess(opts))}]
    end
  end

  @doc """
    Returns docstring of a macro

  """
  def macrodoc(name, opts \\ []) do
    {module, macro_name, arity} = _parse_entity_name(name)

    case Code.ensure_loaded(module) do
      {:module, _} ->
        {:ok, _get_entity_doc(module, macro_name, arity, :macro) |> _postprocess(opts)}

      _ ->
        {:error, "macro not found #{name}"}
    end
  end

  @doc ~S"""
    Returns docstring of a module

    E.g. verbatim

        iex(7)> {:ok, doc} = Extractly.moduledoc("Extractly")
        ...(7)> doc
        "  Provide easy access to information inside the templates rendered by `mix xtra`\n"

    We can use the same options as with `functiondoc`

        iex(8)> {:ok, doc} = Extractly.moduledoc("Extractly", headline: 2)
        ...(8)> doc |> String.split("\n") |> Enum.take(3)
        [
          "## Extractly", "", "  Provide easy access to information inside the templates rendered by `mix xtra`"
        ]

    If we also want to use `functiondoc :all, module: "Extractly"` **after** the call of `moduledoc` we can
    include `:all` in the call of `moduledoc`, which will include function and macro docstrings as well

        iex(9)> [{:ok, moduledoc} | _] =
        ...(9)>   moduledoc("Extractly", headline: 3, include: :all)
        ...(9)> moduledoc
        "### Extractly\n\n  Provide easy access to information inside the templates rendered by `mix xtra`\n"

        iex(10)> [_, {:ok, first_functiondoc} | _] =
        ...(10)>   moduledoc("Extractly", headline: 3, include: :all)
        ...(10)> first_functiondoc |> String.split("\n") |> Enum.take(5)
        [
          "### Extractly.do_not_edit_warning/1",
          "",
          "  Emits a comment including a message not to edit the created file, as it will be recreated from this template.",
          "",
          "  It is a convenience to include this into your templates as follows"
        ]

  """
  def moduledoc(name, opts \\ []) do
    module = String.replace(name, ~r{\A(?:Elixir\.)?}, "Elixir.") |> String.to_atom()
    headline = fdoc_headline(name, opts)

    moduledoc_ =
      case Code.ensure_loaded(module) do
        {:module, _} ->
          _get_moduledoc(module) |> _postprocess(opts) |> _check_nil_moduledoc(name, headline)

        _ ->
          {:error, "module not found #{module}"}
      end

    case Keyword.get(opts, :include) do
      :all ->
        more_docs = functiondoc(:all, Keyword.put(opts, :module, name))
        [moduledoc_ | more_docs]

      nil ->
        moduledoc_

      x ->
        [
          moduledoc_,
          {:error,
           "Illegal value #{x} for include: keyword in moduledoc for module #{name}, legal values are nil and :all"}
        ]
    end
  end

  @doc ~S"""

  Extract Table Of Contents from a markdown document

  The files used for the following doctest can be found [here](https://github.com/RobertDober/extractly/tree/master/test/fixtures)

      iex(11)> lines = [
      ...(11)>         "## Usage",
      ...(11)>         "### API",
      ...(11)>         "#### EarmarkParser.as_ast/2",
      ...(11)>         "### Support",
      ...(11)> ]
      ...(11)> toc(lines, gh_links: true)
      {:ok, [
        "- [Usage](#usage)",
        "  - [API](#api)",
        "    - [EarmarkParser.as_ast/2](#earmarkparseras_ast2)",
        "  - [Support](#support)",
      ]}

      But if you do not want links

      iex(12)> lines = [
      ...(12)>         "## Usage",
      ...(12)>         "### API",
      ...(12)>         "#### EarmarkParser.as_ast/2",
      ...(12)>         "### Support",
      ...(12)> ]
      ...(12)> toc(lines)
      {:ok, [
        "- Usage",
        "  - API",
        "    - EarmarkParser.as_ast/2",
        "  - Support",
      ]}

    In case of bad options an error tuple is returned (no utf8 encoded
    input should ever result in an error_tuple

      iex(13)> lines = [] # options are checked even if input is empty
      ...(13)> toc(lines, no_such_option: "x")
      {:error, "Unsupported option no_such_option"}

  A more detailed description can be found in `Extractly.Toc`'s docstrings

  """
  def toc(markdown_doc, options \\ []) do
    case markdown_doc |> Extractly.Tools.lines_from_source() |> Extractly.Toc.render(options) do
      {:error, message} -> {:error, message}
      data              -> {:ok, data}
    end
  end

  defp _check_nil_moduledoc(moduledoc_or_nil, name, headline)

  defp _check_nil_moduledoc(nil, name, _hl),
    do: {:error, "module #{name} does not have a moduledoc"}

  defp _check_nil_moduledoc(doc, _name, headline), do: {:ok, headline <> doc}

  @doc ~S"""
  Returns the output of a mix task
    Ex:

      iex(14)> Extractly.task("cmd", ~W[echo 42])
      "42\n"

      iex(15)> try do
      ...(15)>   Extractly.task("xxx")
      ...(15)> rescue
      ...(15)>   e in RuntimeError -> e.message |> String.split("\n") |> hd()
      ...(15)> end
      "The following output was produced wih error code 1"

  """
  def task(task, args \\ [])

  def task(task, args) do
    case System.cmd("mix", [task | args]) do
      {output, 0} ->
        output

      {output, error} ->
        raise "The following output was produced wih error code #{error}\n#{output}"
    end
  end

  @doc """
  A convenience method to access this libraries version
  """
  def version do
    :application.ensure_started(:extractly)
    with {:ok, version} = :application.get_key(:extractly, :vsn), do: to_string(version)
  end

  defp _all_functiondocs(module_name, opts) do
    module = "Elixir.#{module_name}" |> String.to_atom()

    case Code.ensure_loaded(module) do
      {:module, _} -> _get_functiondocs(module, opts)
      _ -> [{:error, "cannot load module `#{module}'"}]
    end
  end

  defp _extract_functiondoc(function_info)

  defp _extract_functiondoc({_, _, _, doc_map, _}) when is_map(doc_map) do
    case doc_map do
      %{"en" => docstring} -> docstring
      _ -> nil
    end
  end

  defp _extract_functiondoc(_) do
    nil
  end

  defp _extract_functiondoc_with_headline(
         {{_, function_name, function_arity}, _, _, _, _} = function_info,
         opts
       ) do
    module_name = Keyword.get(opts, :module)
    full_name = "#{module_name}.#{function_name}/#{function_arity}"

    case _extract_functiondoc(function_info) do
      nil -> {:error, "functiondoc for #{full_name} not found"}
      doc -> {:ok, fdoc_headline(full_name, opts) <> (doc |> _postprocess(opts))}
    end
  end

  defp _functiondoc(name) do
    {module, function_name, arity} = _parse_entity_name(name)

    case Code.ensure_loaded(module) do
      {:module, _} -> _get_entity_doc(module, function_name, arity, :function)
      _ -> nil
    end
  end

  defp _get_entity_doc(module, name, arity, entity_type) do
    if function_exported?(module, :__info__, 1) do
      {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)
      Enum.find_value(docs, &_find_entity_doc(&1, name, arity, entity_type))
    end
  end

  defp _get_functiondocs(module, opts) do
    if function_exported?(module, :__info__, 1) do
      {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)

      docs
      |> Enum.map(&_extract_functiondoc_with_headline(&1, opts))
      |> Enum.filter(fn {status, _} -> status == :ok end)
    else
      [{:error, "cannot access #{module.__info__ / 1}"}]
    end
  end

  defp _get_moduledoc(module) do
    if function_exported?(module, :__info__, 1) do
      case Code.fetch_docs(module) do
        {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} -> module_doc
        _ -> nil
      end
    end
  end

  defp _find_entity_doc(doctuple, function_name, arity, entity_type) do
    case doctuple do
      {{^entity_type, ^function_name, ^arity}, _anno, _sign, %{"en" => doc}, _metadata} -> doc
      _ -> nil
    end
  end

  defp _parse_entity_name(name) do
    names = String.split(name, ".")
    [func | modules] = Enum.reverse(names)
    module = ["Elixir" | Enum.reverse(modules)] |> Enum.join(".") |> String.to_atom()
    [function_name, arity] = String.split(func, "/")
    function_name = String.to_atom(function_name)
    {arity, _} = Integer.parse(arity)
    {module, function_name, arity}
  end

  defp _postprocess(input, opts)
  defp _postprocess(nil, _opts), do: nil

  defp _postprocess(input, opts) do
    wrap? = Keyword.get(opts, :wrap_code_blocks)
    input_ = Extractly.Directives.process(input, !!wrap?)

    case wrap? do
      nil -> input_
      lang -> wrap_code_blocks(input_, lang)
    end
  end
end
