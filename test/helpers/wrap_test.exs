defmodule Test.Helpers.WrapTest do
  use ExUnit.Case

  @input "\n     iex(0)> code"
  test "an edge case that cannot be produced with the current behavior of docstrings" do
    expected = "\n```ruby\n     iex(0)> code\n```"
    result = Extractly.Helpers.wrap_code_blocks(@input, "ruby")

    assert result == expected
  end
end
#  SPDX-License-Identifier: Apache-2.0
