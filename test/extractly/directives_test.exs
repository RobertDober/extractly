defmodule Test.Extractly.DirectivesTest do
  use ExUnit.Case
  import Extractly, only: [functiondoc: 2]

  test "ignore_line directive" do
    expected = ["Some test", "%extractly%ignore_line (not this one)", ""]
    result = fdoc("Test.Support.DirectivesModule.fn1/0")

    assert result == expected
  end

  test "stop_processing directive at first line" do
    expected = [""]
    result = fdoc("Test.Support.DirectivesModule.fn2/0")

    assert result == expected
  end

  test "incorrect spelling of stop_procesing" do
    expected = ["extractly%stop_processing%", ""]
    result = fdoc("Test.Support.DirectivesModule.fn3/0")

    assert result == expected
  end

  test "combination of all directives" do
    expected = [
      "Line 1",
      "Line 2",
      "Line 3" ]
    result = fdoc("Test.Support.DirectivesModule.fn4/0")

    assert result == expected
  end

  test "forgetting to resume" do
    expected = [ "Forgetting resume" ]
    result = fdoc("Test.Support.DirectivesModule.fn5/0")

    assert result == expected
  end
  defp fdoc(name), do: functiondoc(name, wrap_code_blocks: "") |> String.split("\n")
end
