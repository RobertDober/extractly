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
    names = String.split(name, ".")
    [ func | modules ] = Enum.reverse(names)
    module = ["Elixir" | Enum.reverse(modules)] |> Enum.join(".") |> String.to_atom()
    [ function_name, arity ]  = String.split(func, "/")
    function_name = String.to_atom(function_name)
    {arity, _}    = Integer.parse(arity)

    case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          {:docs_v1, _, :elixir, _, _, _, docs} = Code.fetch_docs(module)
          Enum.find_value(docs, &find_function_doc(&1, function_name, arity))
        else
          nil
        end
        _ -> nil
    end

  end

  @doc """
    Returns docstring of a module (or nil)
    Ex:

        Extractly.moduledoc("Extractly")
  """
  def moduledoc(name) do
    module = String.to_atom("Elixir." <> name)

    case Code.ensure_loaded(module) do
      {:module, _} ->
        if function_exported?(module, :__info__, 1) do
          case Code.fetch_docs(module) do
            {:docs_v1, _, :elixir, _, %{"en" => module_doc}, _, _} -> module_doc
            _ -> nil
          end
        else
          nil
        end
        _ -> nil
    end
  end

  @doc false
  def version do
    :application.ensure_started(:extractly)
    with {:ok, version} = :application.get_key(:extractly, :vsn), do: version
  end

  defp find_function_doc(doctuple, function_name, arity) do
    case doctuple do
      {{:function, ^function_name, ^arity}, _anno, _sign, %{"en" => doc}, _metadata} -> doc
      _                                                                          -> nil
    end
  end

end
