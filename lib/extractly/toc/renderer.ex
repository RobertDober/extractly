  defmodule Extractly.Toc.Renderer do

  alias Extractly.Toc.Renderer.AstRenderer
  alias Extractly.Toc.Renderer.HtmlRenderer

  import Extractly.Tools, only: [repeat_string: 2]

  @moduledoc false

  @doc false

  def render_ast(tuples, options), do: tuples |> _normalize_levels(options) |> AstRenderer.render_ast(options)

  def render_html(tuples, options), do: tuples |> _normalize_levels(options) |> HtmlRenderer.render_html(options)

  def render_md(tuples, options), do: tuples |> _normalize_levels(options) |> _render_md(options)

  def render_push_list(tuples, options), do: tuples |> _normalize_levels(options) |> AstRenderer.render_push_list(options)

  @unlinkables ~r{[^-\w]+}
  defp _make_gh_link(text) do
    link =
    text
    |> String.downcase()
    |> String.replace(~r{\s}, "-")
    |> String.replace(@unlinkables, "")
    "[#{text}](##{link})"
  end

  defp _maybe_remove_gaps(tuples, options)
  defp _maybe_remove_gaps(tuples, %{remove_gaps: true}), do: _remove_gaps(tuples)
  defp _maybe_remove_gaps(tuples, _), do: tuples

  defp _maybe_remove_levels(tuples, options)
  defp _maybe_remove_levels(tuples, %{min_level: 1, max_level: 7}), do: tuples
  defp _maybe_remove_levels(tuples, %{min_level: min, max_level: max}),
    do: _remove_levels(tuples, min..max)

  defp _normalize_levels(levels, options) do
    levels_ = _maybe_remove_levels(levels, options)

    level_translation_map =
      levels_
      |> Enum.reduce(%{0 => true}, fn {l, _}, acc -> Map.put(acc, l, true) end)
      |> Map.keys()
      |> Enum.sort()
      |> Enum.with_index()
      |> Enum.into(%{})

    levels_
      |> Enum.map(fn {l, text} -> {Map.get(level_translation_map, l), text} end)
      |> _maybe_remove_gaps(options)
  end

  defp _remove_gaps(tuples, clevel \\ 1, result \\ [])
  defp _remove_gaps([], _clevel, result), do: Enum.reverse(result)
  defp _remove_gaps([{tlevel, text}|rest], clevel, result) when tlevel <= clevel + 1,
    do: _remove_gaps(rest, tlevel, [{tlevel, text}|result])
  defp _remove_gaps([{_tlevel, text}|rest], clevel, result),
    do: _remove_gaps(rest, clevel+1, [{clevel+1, text}|result])

  defp _remove_levels(tuples, range), do: Enum.filter(tuples, fn {l, _} -> Enum.member?(range, l) end)

  defp _render_md(tuples, options) do
    tuples
    |> Enum.map(&_render_md_entry(&1, options))
  end

  defp _render_md_entry({level, text}, options) do
    header =
      case options.type do
        :ul -> _indent(level, "-")
        :ol -> _indent(level, "1.")
      end

    header <> _render_text(text, options)
  end

  defp _render_text(text, options) do
    cond do
      options.gh_links -> _make_gh_link(text)
      true -> text
    end
  end

  defp _indent(level, str) do
    len = String.length(str) + 1
    lev = level - 1
    repeat_string(" ", lev * len) <> str <> " "
  end
end
