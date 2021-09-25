defmodule Extractly.Toc.Renderer.HtmlRenderer do
  @moduledoc false
  import Extractly.Toc.Renderer.AstRenderer, only: [render_ast: 1]

  def render_html(tuples, options) do
    tuples
    |> render_ast()
    |> _to_html(options)
  end

  defp _to_html(ast, options)
  defp _to_html(list, options) when is_list(list) do
    [ _open_tag(options.type),
      _close_tag(options.type)
    ]
  end

  defp _close_tag(tag), do: "</#{tag}>"
  defp _open_tag(tag), do: "<#{tag}>"

end
