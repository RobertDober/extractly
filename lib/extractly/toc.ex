defmodule Extractly.Toc do

  alias Extractly.Toc.Options

  import Extractly.Toc.Renderer, only: [render_html: 2, render_md: 2]

  @moduledoc ~S"""
  Extract Table Of Contents from a list of lines representing a Markdown document
  """

  @doc ~S"""
  Depending on the options the Table Of Contents extracted from the lines can be
  rendered in different formats, right now we create only Markdown

      iex(1)> render(["# Hello", "## World"])
      ["- Hello",  "  - World"]

  Numbered lists can be created too

      iex(2)> render(["# Hello", "## World"], type: :ol)
      ["1. Hello",  "   1. World"]

  Oftentimes the level of headlines is adapted for output, e.g. `###` for the top
  and `#####` for the second level.

  `render` accounts for that

      iex(3)> render(["### Alpha", "ignored", "##### Alpha.1", "", "### Beta"])
      ["- Alpha", "  - Alpha.1", "- Beta"]

  This is all nice, however a TOC is most useful if links are provided.

  `render` can render Github like links to within the page, here is a real world example
  from a Github README.md file

      iex(4)> lines = """
      ...(4)>         ## Usage
      ...(4)>         ### API
      ...(4)>         #### EarmarkParser.as_ast/2
      ...(4)>         ### Support
      ...(4)>      """ |> String.split("\n")
      ...(4)> render(lines, gh_links: true)
      [
        "- [Usage](#usage)",
        "  - [API](#api)",
        "    - [EarmarkParser.as_ast/2](#earmarkparseras_ast2)",
        "  - [Support](#support)",
      ]

    Sometimes it might be appropriate to generate HTML directly

      iex(5)> render(["## One", "### Two"], format: :html)
      [
        "<ul>",
        "<li>One</li>",
        "<li>",
        "<ul>",
        "<li>Two</li">,
        "</ul>",
        "</li">,
        "</ul">
      ]
  """

  def render(lines, options \\ []), do: lines |> _scan() |> _render(Options.new(options))

  @headline_rgx ~r<\A \s{0,3} (\#{1,7}) \s+ (.*)>x
  defp _scan(lines), do:
    lines
    |> Enum.map(&Regex.run(@headline_rgx, &1))
    |> Enum.filter(& &1)
    |> Enum.map(fn [_, header, text] -> {String.length(header), text} end)

  defp _render(tuples, options), do:  _render_format(tuples, Keyword.get(options, :format, :markdown), options)

  defp _render_format(tuples, format, options)
  defp _render_format(tuples, :markdown, options), do: render_md(tuples, options)
  defp _render_format(tuples, :md, options), do: render_md(tuples, options)
  defp _render_format(tuples, :html, options), do: render_html(tuples, options)
  defp _render_format(_, format, _), do: {:error, "Unsupported format: #{format} in render"}

end
