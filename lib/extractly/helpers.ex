defmodule Extractly.Helpers do
  @moduledoc false

  def fdoc_headline(name, opts) do
    case Keyword.get(opts, :headline) do
      level when is_number(level) -> _fdoc_headline(name, level)
      _                             -> ""
    end
  end

  def wrap_code_blocks(input, lang)
  def wrap_code_blocks(input, lang) when is_binary(input) do
    input
    |> String.split("\n")
    |> wrap_code_blocks(lang)
  end
  def wrap_code_blocks(lines, lang) do
    _wrap(:start, lines, lang, [])
    |> Enum.reverse
    |> Enum.join("\n")
  end


  defp _fdoc_headline(name, level) do
    ( Stream.cycle(~w{#})
      |> Enum.take(level)
      |> Enum.join ) <> " #{name}\n\n"
  end

  @delim "```"
  @empty ~r{\A \s* \z}x
  @iex   ~r[\A \s{4,} (?: iex | \.\.\. ) \( \d+ \) \> ]x
  defp _wrap(state, lines, lang, result)
  defp _wrap(:inner, [], _, result), do: [@delim | result]
  defp _wrap(_, [], _, result), do: result
  defp _wrap(:start, [line|rest], lang, result) do
    if Regex.match?(@empty, line) do
      _wrap(:blank, rest, lang, [line|result])
    else
      _wrap(:start, rest, lang, [line|result])
    end
  end
  defp _wrap(:blank, [line|rest], lang, result) do
    if Regex.match?(@empty, line) do
      _wrap(:blank, rest, lang, [line|result])
    else
      _wrap_from_blank(line, rest, lang, result)
    end
  end
  defp _wrap(:inner, [line|rest], lang, result) do
    if Regex.match?(@empty, line) do
      _wrap(:blank, rest, lang, [line, @delim | result])
    else
      _wrap(:inner, rest, lang, [line|result])
    end
  end

  defp _wrap_from_blank(line, rest, lang, result) do
    if Regex.match?(@iex, line) do
      _wrap(:inner, rest, lang, [line, "#{@delim}#{lang}" | result])
    else
      _wrap(:start, rest, lang, [line|result])
    end
  end
end
#  SPDX-License-Identifier: Apache-2.0
