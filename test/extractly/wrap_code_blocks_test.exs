defmodule Test.Extractly.WrapCodeBlocksTest do
  use ExUnit.Case

  describe "function" do
    @expected """
    And in the function

    ```elixir
        iex(0)> Function Code
        ...(0)> call()
        result
    ```

    """
    test "with all" do
      fdoc = Extractly.functiondoc( :all, module: "Test.Support.DoctestModule", wrap_code_blocks: "elixir" )

      assert fdoc == @expected
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
