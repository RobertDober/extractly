defmodule Test.Extractly.Toc.RenderTest do
  use ExUnit.Case
  doctest Extractly.Toc, import: true

  import Extractly.Toc, only: [render: 1]

  @easy_peasy ["# One Headline"]
  describe "default options, renders Markdown" do
    test "easy_peasy" do
      expected = ["- One Headline"]
      assert render(@easy_peasy)  == expected
    end
  end
end
