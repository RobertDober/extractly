defmodule Support.Module1 do
  @moduledoc """
  Moduledoc of Module1
  """

  @doc """
  Functiondoc of Module1.hello
  """
  def hello do
    :world
  end

  @doc false
  def sample, do: 42

  def missing(a), do: 2*a

  defp add(a, b), do: a+b
end
