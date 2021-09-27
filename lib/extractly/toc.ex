  defmodule Extractly.Toc do

  alias Extractly.Toc.Options

  import Extractly.Toc.Renderer

  @moduledoc ~S"""
  Extract Table Of Contents from a list of lines representing a Markdown document
  """

  @placeholder_pfx "<!---- Extractly Self TOC "
  def placeholder_pfx, do: @placeholder_pfx
  @placeholder_sfx " ---->"
  @doc false
  def placeholder(options),
    do: [ @placeholder_pfx, Options.to_string(options), @placeholder_sfx ] |> Enum.join

  @doc ~S"""
  Depending on the options the Table Of Contents extracted from the lines can be
    rendered in different formats, the default being Markdown

  #### Markdown

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

  ##### Remove Gaps

  Sometimes there will be _gaps_ in the levels of headlines and these holes might
  not reflect semantic but rather stylistic concerns, if this is the case the option
  `remove_gaps` can be set to `true`

      iex(4)> render(["# First", "### Third (but will go to second level)", "## Second"], remove_gaps: true)
      ["- First", "  - Third (but will go to second level)", "  - Second"]


  ##### Github README Links

  This is all nice, however a TOC is most useful if links are provided.

  `render` can render Github like links to within the page, here is a real world example
  from a Github README.md file

      iex(5)> lines = [
      ...(5)>         "## Usage",
      ...(5)>         "### API",
      ...(5)>         "#### EarmarkParser.as_ast/2",
      ...(5)>         "### Support",
      ...(5)> ]
      ...(5)> render(lines, gh_links: true)
      [
        "- [Usage](#usage)",
        "  - [API](#api)",
        "    - [EarmarkParser.as_ast/2](#earmarkparseras_ast2)",
        "  - [Support](#support)",
      ]

  #### HTML

  Sometimes it might be appropriate to generate HTML directly

      iex(6)> render(["## One", "### Two"], format: :html)
      ["<ul>", "<li>One<ul>", "<li>Two</li>", "</ul></li>", "</ul>"]

  ##### Exlcuding levels and changing list styles

  Let us examine these two options with HTML output, they work too for Markdown of course, but are meaningless with the more
  _raw_ output formats

  So we do not want to include levels greater than, say 3, and we also want to ignore top level headlines, probably because only
  one top level part has sublevels

      iex(7)> document = [
      ...(7)> "# Ignore",
      ...(7)> "# Too, but not what's below",
      ...(7)> "## Synopsis",
      ...(7)> "## Description",
      ...(7)> "### API",
      ...(7)> "#### too detailed",
      ...(7)> "### Tips & Tricks",
      ...(7)> "# Ignored again"
      ...(7)> ]
      ...(7)> render(document, format: :html, min_level: 2, max_level: 3, start: 5, type: :ol)
      [
        ~S{<ol start="5">},
        ~S{<li>Synopsis</li>},
        ~S{<li>Description<ol>},
        ~S{<li>API</li>},
        ~S{<li>Tips &amp; Tricks</li>},
        ~S{</ol></li>},
        ~S{</ol>},
      ]

  #### PushList

  Either a linear `PushList`

      iex(8)> render(["# I", "## I.1", "## I.2", "### I.2.(i)", "# II", "### II.1.(ii)"], format: :push_list)
      ["I", :open, "I.1", "I.2", :open, "I.2.(i)", :close, :close, "II", :open, :open, "II.1.(ii)", :close, :close]


  #### AST tree

      iex(9)> render(["# I", "## I.1", "## I.2", "### I.2.(i)", "# II", "### II.1.(ii)"], format: :ast)
      ["I", ["I.1", "I.2", ["I.2.(i)"]], "II", [["II.1.(ii)"]]]

  #### Unsupported Formats


      iex(9)> render(["# Does not really matter"], format: :unknown)
      {:error, "Unsupported format: unknown in render"}

  """

  def render(lines, options \\ [])
  def render({:error, _}=error, _options), do: error
  def render(lines, %Options{}=options), do: lines |> _scan() |> _render(options)
  def render(lines, options) do
    case Options.new(options) do
      {:ok, options_} -> lines |> _scan() |> _render(options_)
      error           -> error
    end
  end

  @headline_rgx ~r<\A \s{0,3} (\#{1,7}) \s+ (.*)>x
  defp _scan(lines), do:
    lines
    |> Enum.map(&Regex.run(@headline_rgx, &1))
    |> Enum.filter(& &1)
    |> Enum.map(fn [_, header, text] -> {String.length(header), text} end)

  defp _render(tuples, options), do: _render_format(tuples, options.format || :markdown, options)

  defp _render_format(tuples, format, options)
  defp _render_format(tuples, :markdown, options), do: render_md(tuples, options)
  defp _render_format(tuples, :html, options), do: render_html(tuples, options)
  defp _render_format(tuples, :push_list, options), do: render_push_list(tuples, options)
  defp _render_format(tuples, :ast, options), do: render_ast(tuples, options)
  defp _render_format(_, format, _), do: {:error, "Unsupported format: #{format} in render"}

end
