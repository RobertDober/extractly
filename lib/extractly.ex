defmodule Extractly do
  @moduledoc """
    Provide easy access to information inside the templates rendered by `mix xtra`
  """


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
  """
  def functiondoc(name) do
    {module, function_name, arity} = _parse_function_name(name)

    case Code.ensure_loaded(module) do
      {:module, _} -> _get_functiondoc(module, function_name, arity)
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


  defp _get_functiondoc(module, function_name, arity) do
    if function_exported?(module, :__info__, 1) do
      {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)
      Enum.find_value(docs, &_find_function_doc(&1, function_name, arity))
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

  defp _find_function_doc(doctuple, function_name, arity) do
    case doctuple do
      {{:function, ^function_name, ^arity}, _anno, _sign, %{"en" => doc}, _metadata} -> doc
      _ -> nil
    end
  end

  defp _parse_function_name(name) do
    names = String.split(name, ".")
    [func | modules] = Enum.reverse(names)
    module = ["Elixir" | Enum.reverse(modules)] |> Enum.join(".") |> String.to_atom()
    [function_name, arity] = String.split(func, "/")
    function_name = String.to_atom(function_name)
    {arity, _} = Integer.parse(arity)
    {module, function_name, arity}
  end
end
