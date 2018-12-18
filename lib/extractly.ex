defmodule Extractly do

  @moduledoc """
    Interface into documentation of Elixir modules
  """


  def functiondoc(name) do
    names = String.split(name, ".")
    [ func | modules ] = Enum.reverse(names)
    module = ["Elixir" | Enum.reverse(modules)] |> Enum.join(".") |> String.to_atom()
    [ function_name, arity ]  = String.split(func, "/")
    function_name = String.to_atom(function_name)
    {arity, _}    = Integer.parse(arity)

    markdown = case Code.ensure_loaded(module) do
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

  defp find_function_doc(doctuple, function_name, arity) do
    case doctuple do
      {{:function, ^function_name, ^arity}, _anno, _sign, %{"en" => doc}, _metadata} -> doc
      _                                                                          -> nil
    end
  end

end
