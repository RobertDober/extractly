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

  @doc """
    Returns docstring of a function (or nil)
    Ex:

        iex(0)> Extractly.functiondoc("Extractly.moduledoc/1")
        [ "  Returns docstring of a module (or nil)",
          "  Ex:",
          "",
          "      Extractly.moduledoc(\\"Extractly\\")",
          ""
          ] |> Enum.join("\\n")

    We can also pass a list of functions to get their docs concatenated

        iex(1)> out = Extractly.functiondoc(["Extractly.moduledoc/1", "Extactly.functiondoc/2"])
        ...(1)> # as we are inside the docstring we required we would need a quine to check for the
        ...(1)> # output, let us simplify
        ...(1)> String.split(out, "\\n") |> Enum.take(5)
        [ "  Returns docstring of a module (or nil)",
          "  Ex:",
          "",
          "      Extractly.moduledoc(\\"Extractly\\")",
          ""]

    If all the functions are in the same module the following form can be used

        iex(2)> out = Extractly.functiondoc(["moduledoc/1", "functiondoc/2"], module: "Extractly")
        ...(2)> String.split(out, "\\n") |> hd()
        "  Returns docstring of a module (or nil)"

    However it is convenient to add a markdown headline before each functiondoc, especially in these cases,
    it can be done by indicating the `headline: level` option

        iex(3)> out = Extractly.functiondoc(["moduledoc/1", "functiondoc/2"], module: "Extractly", headline: 2)
        ...(3)> String.split(out, "\\n") |> Enum.take(3)
        [ "## Extractly.moduledoc/1",
          "",
          "  Returns docstring of a module (or nil)"]

    Often times we are interested by **all** public functiondocs...

        iex(4)> out = Extractly.functiondoc(:all, module: "Extractly", headline: 2)
        ...(4)> String.split(out, "\\n") |> Enum.take(3)
        [ "## Extractly.do_not_edit_warning/1",
          "",
          "  Emits a comment including a message not to edit the created file, as it will be recreated from this template."]

  """
  def functiondoc(name, opts \\ [])
  def functiondoc(:all, opts) do
    case Keyword.get(opts, :module) do
        nil         -> "<!-- ERROR: No module given for `functiondoc(:all, ...)` -->"
        module_name -> _all_functiondocs( module_name, opts )
    end
  end
  def functiondoc(names, opts) when is_list(names) do
    prefix =
      case Keyword.get(opts, :module) do
        nil         -> ""
        module_name -> "#{module_name}."
      end

    names
    |> Enum.map(&functiondoc("#{prefix}#{&1}", opts))
    |> Enum.join
  end
  def functiondoc(name, opts) when is_binary(name) do
    headline = fdoc_headline(name, opts)
    case _functiondoc(name) do
      nil -> nil
      doc -> headline <> doc
    end
  end

  @doc """
    Returns docstring of a macro (or nil)

    Same naming convention for macros as for functions.
  """
  def macrodoc(name) do
    {module, macro_name, arity} = _parse_entity_name(name)

    case Code.ensure_loaded(module) do
      {:module, _} -> _get_entity_doc(module, macro_name, arity, :macro)
      _ -> nil
    end
  end

  @doc """
    Returns docstring of a module (or nil)
    Ex:

        Extractly.moduledoc("Extractly")
  """
  def moduledoc(name) do
    module = String.replace(name, ~r{\A(?:Elixir\.)?}, "Elixir.") |> String.to_atom

    case Code.ensure_loaded(module) do
      {:module, _} -> _get_moduledoc(module)
      _ -> nil
    end
  end

  @doc ~S"""
  Returns the output of a mix task
    Ex:

      iex(5)> Extractly.task("cmd", ~W[echo 42])
      "42\\n"

      iex(0)> Extractly.task("xxx")
      "***Error, the following output was produced wih error code 1\nCompiling 1 file (.ex)\n"
  """
  def task(task, args \\ [])
  def task(task, args) do
    case System.cmd("mix", [task | args]) do
      {output, 0} -> output
      {output, error} -> "***Error, the following output was produced wih error code #{error}\n#{output}"
    end
  end

  @doc false
  def version do
    :application.ensure_started(:extractly)
    with {:ok, version} = :application.get_key(:extractly, :vsn), do: to_string(version)
  end


  defp _all_functiondocs(module_name, opts) do
    module = "Elixir.#{module_name}" |> String.to_atom
    case Code.ensure_loaded(module) do
      {:module, _} ->  _get_functiondocs(module, opts)
      _ -> "<!-- ERROR cannot load module `#{module}' -->"
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
      nil -> nil
      doc -> fdoc_headline( full_name, opts ) <> doc
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
      |> Enum.join
    else
      "<!-- ERROR cannot access #{module.__info__/1} -->"
    end
  end

  defp _get_moduledoc(module) do
    if function_exported?(module, :__info__, 1) do
      case Code.fetch_docs(module) do
        {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} -> module_doc
        _ -> nil
      end
      # TODO: Check under which circomstances this code is needed if at all.
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
end
