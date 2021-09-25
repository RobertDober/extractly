defmodule Test.Extractly.Toc.Render.RenderAstTest do
  use ExUnit.Case

    import Extractly.Toc.Renderer.AstRenderer, only: [render_ast: 1]

  @simple [ {1, "a"}, {3, "a0a"}, {3, "a0b"}, {2, "ab"} ]
  @medium [ {1, "x"}, {3, "x0x"}, {3, "x0y"}, {1, "y"}, {1, "z"}, {4, "z00x"} ]
  describe "render ast on normalized tuples" do
    test "simple" do
      expected = ["a", [["a0a", "a0b"], "ab"]]
      result = render_ast(@simple)

      assert result == expected
    end
    test "medium" do
      expected = [
        "x", [["x0x", "x0y"]], "y", "z", [[["z00x"]]]
      ]
      result = render_ast(@medium)

      assert result == expected
    end
  end
end
