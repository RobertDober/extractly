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
  def do_not_edit_warning( opts \\ []), do: DoNotEdit.warning(opts)

  @doc ~S"""
    Returns docstring of a function
    Ex:

        iex(0)> {:ok, lines} = Extractly.functiondoc("Extractly.moduledoc/2") |> hd()
        ...(0)> lines |> String.split("\n") |> Enum.take(3)
        ["  Returns docstring of a module (or nil)", "  Ex:", ""]

    We can also pass a list of functions to get their docs concatenated

        iex(1)> [{:ok, moduledoc}, {:error, message}] = Extractly.functiondoc(["Extractly.moduledoc/2", "Extactly.functiondoc/2"])
        ...(1)> moduledoc |> String.split("\n") |> Enum.take(4)
        [ "  Returns docstring ofaa module",
          "  Ex:",
          "",
          "      Extractly.moduledoc(\"Extractly\")",
          ""]
        ...(1)> message
        "Function doc for function Extactly.functiondoc/2 not found"

    If all the functions are in the same module the following form can be used

        iex(2)> [{:ok, out}, _] = Extractly.functiondoc(["moduledoc/2", "functiondoc/2"], module: "Extractly")
        ...(2)> String.split(out, "\n") |> hd()
        "  Returns docstring of a module (or nil)"

    However it is convenient to add a markdown headline before each functiondoc, especially in these cases,
    it can be done by indicating the `headline: level` option

        iex(3)> [{:ok, moduledoc}, {:ok, functiondoc}] = Extractly.functiondoc(["moduledoc/2", "functiondoc/2"], module: "Extractly", headline: 2)
        ...(3)> moduledoc |> String.split("\n") |> Enum.take(3)
        [ "## Extractly.moduledoc/2",
          "",
          "  Returns docstring of a module"]
        ...(3)> functiondoc |> String.split("\n") |> Enum.take(3)
        [ "## Extractly.functiondoc/2",
          "",
          "  Returns docstring of a function"]

    Often times we are interested by **all** public functiondocs...

        iex(4)> [{:ok, out}|_] = Extractly.functiondoc(:all, module: "Extractly", headline: 2)
        ...(4)> String.split(out, "\n") |> Enum.take(3)
        [ "## Extractly.do_not_edit_warning/1",
          "",
          "  Emits a comment including a message not to edit the created file, as it will be recreated from this template."]

    We can specify a language to wrap indented code blocks into ` ```elixir\n...\n``` `

    Here is an example

        iex(0)> [ok: doc] = Extractly.functiondoc("Extractly.functiondoc/2", wrap_code_blocks: "elixir")
        ...(0)> doc |> String.split("\n") |> Enum.take(10)
        [ "  Returns docstring of a function",
          "  Ex:",
          "",
          "```elixir",
          "      iex(0)> {:ok, lines} = Extractly.functiondoc(\"Extractly.moduledoc/2\") |> hd()",
          "      ...(0)> lines |> String.split(\"\\n\") |> Enum.take(3)",
          "      [\"  Returns docstring of a module (or nil)\", \"  Ex:\", \"\"]",
          "```",
          "",
          "  We can also pass a list of functions to get their docs concatenated"]

  """
  def functiondoc(name, opts \\ [])
  def functiondoc(:all, opts) do
    case Keyword.get(opts, :module) do
        nil         -> [{:error, "No module given for `functiondoc(:all, ...)`"}]
        module_name -> _all_functiondocs(module_name, opts)
    end
  end
  def functiondoc(names, opts) when is_list(names) do
    prefix =
      case Keyword.get(opts, :module) do
        nil         -> ""
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
    Returns docstring of a macro (or nil)

    Same naming convention for macros as for functions.
  """
  def macrodoc(name, opts\\[]) do
    {module, macro_name, arity} = _parse_entity_name(name)

    case Code.ensure_loaded(module) do
      {:module, _} -> {:ok, _get_entity_doc(module, macro_name, arity, :macro) |> _postprocess(opts)}
      _ -> {:error, "macro not found #{name}"}
    end
  end

  @doc """
    Returns docstring of a module (or nil)
    Ex:

        Extractly.moduledoc("Extractly")
  """
  def moduledoc(name, opts \\ []) do
    module = String.replace(name, ~r{\A(?:Elixir\.)?}, "Elixir.") |> String.to_atom

    case Code.ensure_loaded(module) do
      {:module, _} -> _get_moduledoc(module) |> _postprocess(opts) |> _check_nil_moduledoc(name)
      _ -> {:error, "module not found #{module}"}
    end
  end

  defp _check_nil_moduledoc(moduledoc_or_nil, name)
  defp _check_nil_moduledoc(nil, name), do: {:error, "module #{name} does not have a moduledoc"}
  defp _check_nil_moduledoc(false, name), do: {:error, "module #{name} does not have a moduledoc"}
  defp _check_nil_moduledoc(doc, _name), do: {:ok, doc}

  @doc ~S"""
  Returns the output of a mix task
    Ex:

      iex(5)> Extractly.task("cmd", ~W[echo 42])
      "42\n"

      iex(0)> Extractly.task("xxx") |> String.split("\n")|> hd()
      "***Error, the following output was produced wih error code 1"
  """
  def task(task, args \\ [])
  def task(task, args) do
    case System.cmd("mix", [task | args]) do
      {output, 0} -> output
      {output, error} -> "***Error, the following output was produced wih error code #{error}\n#{output}"
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
    module = "Elixir.#{module_name}" |> String.to_atom
    case Code.ensure_loaded(module) do
      {:module, _} ->  _get_functiondocs(module, opts)
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

  defp _extract_functiondoc_with_headline({{_, function_name, function_arity},_,_,_,_}=function_info, opts) do
    module_name = Keyword.get(opts, :module)
    full_name = "#{module_name}.#{function_name}/#{function_arity}"
    case _extract_functiondoc(function_info) do
      nil -> {:error, "functiondoc for #{full_name} not found"}
      doc -> {:ok, fdoc_headline( full_name, opts ) <> (doc |> _postprocess(opts))}
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
      [{:error, "cannot access #{module.__info__/1}"}]
    end
  end

  defp _get_moduledoc(module) do
    if function_exported?(module, :__info__, 1) do
      case Code.fetch_docs(module) do
        {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} -> module_doc
        _ -> nil
      end
      # TODO: Check under which circumstances this code is needed if at all.
      # case Code.get_docs(module, :moduledoc) do
      #   {_, docs} when is_binary(docs) ->
      #     docs
      #     _ -> nil
      # end
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
