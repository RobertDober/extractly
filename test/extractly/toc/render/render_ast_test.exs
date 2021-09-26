defmodule Test.Extractly.Toc.Render.RenderAstTest do
  use ExUnit.Case

  doctest Extractly.Toc.Renderer.AstRenderer, import: true
  import Extractly.Toc.Renderer.AstRenderer, only: [make_push_list: 1, render_ast: 1]

  @simple [ {1, "a"}, {3, "a0a"}, {3, "a0b"}, {2, "ab"} ]
  @medium [ {1, "x"}, {3, "x0x"}, {3, "x0y"}, {1, "y"}, {1, "z"}, {4, "z00x"} ]
  @real [
    {1, "Extractly"},
    {2, "Extractly"},
    {2, "Extractly.do_not_edit_warning/1"},
    {2, "Extractly.functiondoc/2"},
    {2, "Extractly.macrodoc/2"},
    {2, "Extractly.moduledoc/2"},
    {2, "Extractly.task/2"},
    {2, "Extractly.toc/2"},
    {2, "Extractly.version/0"},
    {2, "Mix.Tasks.Xtra"},
    {2,
      "Mix task to Transform EEx templates in the context of the `Extractly` module."},
    {2, "Mix.Tasks.Xtra.Help"},
    {3, "Usage:"},
    {4, "Options:"},
    {4, "Argument:"},
    {2, "Author"},
    {1, "LICENSE"}
  ]
  describe "push list" do
    test "simple" do
      expected = ["a", :open, :open, "a0a", "a0b", :close, "ab", :close]
      result = make_push_list(@simple)

      assert result == expected
    end
    test "real" do
      expected = ["Extractly", :open, "Extractly", "Extractly.do_not_edit_warning/1",
        "Extractly.functiondoc/2", "Extractly.macrodoc/2", "Extractly.moduledoc/2",
        "Extractly.task/2", "Extractly.toc/2", "Extractly.version/0", "Mix.Tasks.Xtra",
        "Mix task to Transform EEx templates in the context of the `Extractly` module.",
        "Mix.Tasks.Xtra.Help", :open, "Usage:", :open, "Options:", "Argument:", :close,
        :close, "Author", :close, "LICENSE"]
      result = make_push_list(@real)

      assert result == expected
    end
  end

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
