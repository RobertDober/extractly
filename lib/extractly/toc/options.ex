defmodule Extractly.Toc.Options do

  @moduledoc false

  defstruct format: :markdown,
    gh_links: false,
    max_level: 7,
    min_level: 1,
    remove_gaps: false,
    start: 1,
    type: :ul

  # %Extractly.Toc.Options{format: :markdown, gh_links: false, max_level: 7, min_level: 1, remove_gaps: false, start: 1, type: :ul}
  # This only works because no values are strings and do not contain ",", "{", or "}"
  @parse_rgx ~r< \{ (.*) \} >x
  def from_string!(str) do
    case  Regex.run(@parse_rgx, str) do
      [_, content] -> _parse_str(content, new!())
      _ -> raise "Illegal Options representation: #{str}"
    end
  end

  def new(from \\ []) do
    try do
      {:ok, new!(from)}
    rescue
      ke in KeyError -> {:error, "Unsupported option #{ke.key}"}
    end
  end

  def new!(from \\ []), do: struct!(__MODULE__, from)

  def to_string(%__MODULE__{}=options), do: inspect(options)

  @transformers %{
    format: &__MODULE__._make_sym/1,
    gh_links: &__MODULE__._make_bool/1,
    max_level: &__MODULE__._make_int/1,
    min_level: &__MODULE__._make_int/1,
    remove_gaps: &__MODULE__._make_bool/1,
    start: &__MODULE__._make_int/1,
    type: &__MODULE__._make_sym/1
  }


  defp _add_parsed_option(key, value, options) do
    Map.put(options, key, Map.fetch!(@transformers, key).(value))
  end

  def _make_bool(str) do
    cond do
      str == "true" -> true
      str == "false" -> false
      true -> raise "Illegal boolean value #{str}"
    end
  end
  def _make_int(str) do
    case Integer.parse(str) do
      {value, ""} -> value
      _           -> raise "Illegal integer value #{str}"
    end
  end
  def _make_sym(str) do
    str
    |> String.trim_leading(":")
    |> String.to_atom
  end

  # This only works because no values are strings and do not contain ",", "{", or "}"
  @elergx ~r{ (\w+): \s (\S+)(?:,|\z) }x
  defp _parse_str(str, options) do
    @elergx
    |> Regex.scan(str)
    |> Enum.reduce(options, fn [_, key, value], options_ -> _add_parsed_option(String.to_atom(key), value, options_) end)
  end
end
#  SPDX-License-Identifier: Apache-2.0
