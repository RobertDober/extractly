  defmodule Extractly.Toc.Renderer do

  alias Extractly.Toc.Renderer.AstRenderer
  alias Extractly.Toc.Renderer.HtmlRenderer

  import Extractly.Tools, only: [repeat_string: 2]

  @moduledoc false

  @doc false
  defp normalize_levels(levels) do
    level_translation_map =
      levels
      |> Enum.reduce(%{0 => true}, fn {l, _}, acc -> Map.put(acc, l, true) end)
      |> Map.keys()
      |> Enum.sort()
      |> Enum.with_index()
      |> Enum.into(%{})

    levels
    |> Enum.map(fn {l, text} -> {Map.get(level_translation_map, l), text} end)
  end

  def render_ast(tuples, options), do: tuples |> normalize_levels() |> AstRenderer.render_ast(options)

  def render_html(tuples, options), do: tuples |> normalize_levels() |> HtmlRenderer.render_html(options)

  def render_md(tuples, options), do: tuples |> normalize_levels() |> _render_md(options)

  def render_push_list(tuples, options), do: tuples |> normalize_levels() |> AstRenderer.make_push_list(options)

  @unlinkables ~r{\W+}
  defp _make_gh_link(text) do
    link =
    text
    |> String.downcase()
    |> String.replace(@unlinkables, "")
    "[#{text}](##{link})"
  end

  defp normalize_levels(levels) do
    level_translation_map =
      levels
      |> Enum.reduce(%{0 => true}, fn {l, _}, acc -> Map.put(acc, l, true) end)
      |> Map.keys()
      |> Enum.sort()
      |> Enum.with_index()
      |> Enum.into(%{})

    levels
    |> Enum.map(fn {l, text} -> {Map.get(level_translation_map, l), text} end)
  end

  defp _render_html(tuples, options, result)
  defp _render_html([], _options, result), do: Enum.reverse(result)

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
