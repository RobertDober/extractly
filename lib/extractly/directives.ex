defmodule Extractly.Directives do
  @moduledoc """
  Processes the extracted docstring according to `%extractly%<directive>%` directives
  """

  @doc """
  
  """
  def process(lines, wrap?)
  def process(lines, wrap?) when is_binary(lines), do: lines |> String.split("\n") |> process(wrap?)
  def process(lines, true), do: _copy(lines, []) |> Enum.reverse
  def process(lines, _), do: _copy(lines, []) |> Enum.reverse |> Enum.join("\n")

  @ignore_line_directive ~r{(?:\s|^)%extractly%ignore_line%(?:\s|$)}
  @resume_processing_directive ~r{(?:\s|^)%extractly%resume_processing%(?:\s|$)}
  @stop_processing_directive ~r{(?:\s|^)%extractly%stop_processing%(?:\s|$)}
  @suspend_processing_directive ~r{(?:\s|^)%extractly%suspend_processing%(?:\s|$)}
  defp _copy([], result), do: result
  defp _copy([line|rest], result) do
    cond do
      String.match?(line, @ignore_line_directive) -> _copy(rest, result)
      String.match?(line, @resume_processing_directive) -> _copy(rest, result) # A warning might be in order
      String.match?(line, @stop_processing_directive) -> result
      String.match?(line, @suspend_processing_directive) -> _skip(rest, result)
      true -> _copy(rest, [line|result])
    end
  end

  defp _skip([], result), do: result # A warning might be in order
  defp _skip([line|rest], result) do
    cond do
      String.match?(line, @resume_processing_directive) -> _copy(rest, result)
      # String.match?(line, @ignore_line_directive) -> _skip(rest, result) # A warning might be in order
      # String.match?(line, @suspend_processing_directive) -> _skip(rest, result) # A warning might be in order
      # String.match?(line, @suspend_processing_directive) -> _skip(rest, result) # A warning might be in order
      String.match?(line, @stop_processing_directive) -> result
      true -> _skip(rest, result)
    end
  end
end
