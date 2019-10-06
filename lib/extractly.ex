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

        iex(1)> Extractly.functiondoc("Extractly.moduledoc/1")
        [ "  Returns docstring of a module (or nil)",
          "  Ex:",
          "", 
          "      Extractly.moduledoc(\\"Extractly\\")",
          ""
          ] |> Enum.join("\\n")

    We can also pass a list of functions to get their docs concatenated

        iex(2)> out = Extractly.functiondoc(["Extractly.moduledoc/1", "Extactly.functiondoc/2"])
        ...(2)> # as we are inside the docstring we required we would need a quine to check for the
        ...(2)> # output, let us simplify
        ...(2)> String.split(out, "\\n") |> Enum.take(5)
        [ "  Returns docstring of a module (or nil)",
          "  Ex:",
          "", 
          "      Extractly.moduledoc(\\"Extractly\\")",
          ""]

  """
  def functiondoc(name, opts \\ [])
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
  
  @doc false
  def version do
    :application.ensure_started(:extractly)
    with {:ok, version} = :application.get_key(:extractly, :vsn), do: to_string(version)
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
