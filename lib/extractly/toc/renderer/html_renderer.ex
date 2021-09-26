  defmodule Extractly.Toc.Renderer.HtmlRenderer do
  @moduledoc false
  import Extractly.Toc.Renderer.AstRenderer, only: [make_push_list: 1]


  # TODO: Replace 'ul' and 'li' with values depending on options
  # TODO: Escap text when html is created
  def render_html(tuples, options\\[]) do
    tuples
    |> make_push_list()
    |> _to_html(options, ["<ul>"])
  end

  defp _to_html(push_list, options, result)
  defp _to_html([], _options, result), do: Enum.reverse(["</ul>"|result])
  defp _to_html([:close | rest], options, result) do
    _to_html(rest, options, ["</ul></li>"|result])
  end
  defp _to_html([:open | rest], options, result) do
    _to_html(rest, options, ["<li><ul>"|result])
  end
  defp _to_html([head, :open | rest], options, result) when is_binary(head) do
    _to_html(rest, options, ["<li>#{head}<ul>" | result])
  end
  defp _to_html([head | rest], options, result) when is_binary(head) do
    _to_html(rest, options, ["<li>#{head}</li>"|result])
  end

  defp _close_tag(tag), do: "</#{tag}>"
  defp _open_tag(tag), do: "<#{tag}>"

end
