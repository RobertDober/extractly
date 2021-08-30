defmodule Test.Extractly.DirectivesTest do
  use ExUnit.Case
  import Extractly, only: [functiondoc: 2]

  test "ignore_line directive" do
    expected = ["Some test", "%extractly%ignore_line (not this one)", ""]
    result = fdoc("Test.Support.DirectivesModule.fn1/0")

    assert result == expected
  end

  defp fdoc(name), do: functiondoc(name, wrap_code_blocks: "") |> String.split("\n")
end
