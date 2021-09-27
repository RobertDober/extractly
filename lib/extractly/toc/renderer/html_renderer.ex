  defmodule Extractly.Toc.Renderer.HtmlRenderer do
  @moduledoc false
  import Extractly.Toc.Renderer.AstRenderer, only: [render_push_list: 1]


  # TODO: Replace 'ul' and 'li' with values depending on options
  # TODO: Escap text when html is created
  def render_html(tuples, options\\[]) do
    tuples
    |> render_push_list()
    |> _to_html(options, [_open_tag(options, true)])
  end

  defp _to_html(push_list, options, result)
  defp _to_html([], options, result), do: Enum.reverse([_close_tag(options)|result])
  defp _to_html([:close | rest], options, result) do
    _to_html(rest, options, ["#{_close_tag(options)}</li>"|result])
  end
  defp _to_html([:open | rest], options, result) do
    _to_html(rest, options, ["<li>#{_open_tag(options)}"|result])
  end
  defp _to_html([head, :open | rest], options, result) when is_binary(head) do
    _to_html(rest, options, ["<li>#{_escape(head)}#{_open_tag(options)}" | result])
  end
  defp _to_html([head | rest], options, result) when is_binary(head) do
    _to_html(rest, options, ["<li>#{_escape(head)}</li>"|result])
  end

  defp _close_tag(%{type: type}), do: "</#{type}>"

  defp _open_tag(options, include_start? \\ false)
  defp _open_tag(%{type: type}, false), do: "<#{type}>"
  defp _open_tag(%{type: type, start: 1}, _), do: "<#{type}>"
  defp _open_tag(%{type: type, start: start}, true), do: ~s{<#{type} start="#{start}">}

  @amp_rgx ~r{&(?!#?\w+;)}
  defp _escape(html), do:
    Regex.replace(@amp_rgx, html, "&amp;")
    |> String.replace("<", "&lt;")
    |> String.replace(">", "&gt;")
    |> String.replace("\"", "&quot;")
    |> String.replace("'", "&#39;")

end
