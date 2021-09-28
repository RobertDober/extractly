  defmodule Test.Extractly.Toc.RenderTest do
  use ExUnit.Case
  doctest Extractly.Toc, import: true

  import Extractly.Toc, only: [render: 1, render: 2]

  @easy_peasy ["# One Headline"]
  describe "default options, renders Markdown" do
    test "easy_peasy" do
      expected = ["- One Headline"]
      assert render(@easy_peasy)  == expected
    end
    test "with gh links" do
      expected = ["- [One Headline](#one-headline)"]
      assert render(@easy_peasy, gh_links: true)  == expected
    end
    test "more stress on gh links" do
      input = ["# &function/2"]
      expected = ["- [&function/2](#function2)"]
      assert render(input, gh_links: true) == expected
    end
  end
end
