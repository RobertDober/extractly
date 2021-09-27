defmodule Test.Extractly.Toc.Render.RenderHtmlTest do
  use ExUnit.Case

  # doctest Extractly.Toc.Renderer.HtmlRenderer, import: true
  alias Extractly.Toc

  @simple [ {1, "a"}, {3, "a0a"}, {3, "a0b"}, {2, "ab"} ]
  @medium [ {1, "x"}, {3, "x0x"}, {3, "x0y"}, {1, "y"}, {1, "z"}, {4, "z00x"} ]
  describe "render ast on normalized tuples" do
    test "simple" do
      expected = [
        "<ul>",
        "<li>a<ul>",
        "<li><ul>",
        "<li>a0a</li>",
        "<li>a0b</li>",
        "</ul></li>",
        "<li>ab</li>",
        "</ul></li>",
        "</ul>",
      ]
      result = render_html(@simple)

      assert result == expected
    end

    test "medium" do
      expected = [
        "<ul>",
        "<li>x<ul>",
        "<li><ul>",
        "<li>x0x</li>",
        "<li>x0y</li>",
        "</ul></li>",
        "</ul></li>",
        "<li>y</li>",
        "<li>z<ul>",
        "<li><ul>",
        "<li><ul>",
        "<li>z00x</li>",
        "</ul></li>",
        "</ul></li>",
        "</ul></li>",
        "</ul>",
      ]
      result = render_html(@medium)

      assert result == expected
    end

    defp render_html(html, options \\ []),
    do: Toc.Renderer.HtmlRenderer.render_html(html, struct(Toc.Options, options))
  end

  describe "options and escaping" do
    test "ignoring levels, ordered list with start and escaping" do
       document = [
       "# Ignore",
       "# Too, but not what's below",
       "## Synopsis",
       "## Description",
       "### API",
       "#### too detailed",
       "### Tips & Tricks",
       "# Ignored again"
       ]
      expected = [
        ~S{<ol start="5">},
        ~S{<li>Synopsis</li>},
        ~S{<li>Description<ol>},
        ~S{<li>API</li>},
        ~S{<li>Tips &amp; Tricks</li>},
        ~S{</ol></li>},
        ~S{</ol>},
      ]
      result = Toc.render(document, format: :html, min_level: 2, max_level: 3, start: 5, type: :ol)

      assert result == expected
    end
  end
end
