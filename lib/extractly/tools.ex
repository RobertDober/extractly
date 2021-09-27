defmodule Extractly.Tools do

  @doc ~S"""
    Extract lines from either a

    - file given by name
    - a Stream
    - or returns the list passed in as in a NOP
  """
  def lines_from_source(source) do
    try do
      _lines_from_source(source)
    rescue
      _ -> {:error, "could not read from #{inspect source}"}
    end
  end

  defp _lines_from_source(source)
  defp _lines_from_source(filename) when is_binary(filename),
    do: filename |> File.stream!([:utf8], :line) |> Enum.to_list
  defp _lines_from_source(lines) when is_list(lines),
    do: lines
  defp _lines_from_source(stream),
    do: stream |> Enum.to_list

  @doc ~S"""
  A convenience function to repeat a string, it is a shortform
  for

  ```elixir
  [str] |> Stream.cycle |> Enum.take(n) |> Enum.join
  ```
  """
  @spec repeat_string(binary(), non_neg_integer()) :: binary()
  def repeat_string(string, times), do:
    [string] |> Stream.cycle |> Enum.take(times) |> Enum.join

end
