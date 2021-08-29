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
      fdoc = Extractly.functiondoc(:all, module: "Test.Support.DoctestModule", wrap_code_blocks: "elixir")

      assert fdoc == @expected
    end

    test "with explicit" do
      fdoc = Extractly.functiondoc("Test.Support.DoctestModule.fun/0", wrap_code_blocks: "elixir")

      assert fdoc == @expected
    end
  end

  describe "module" do
    @expected """

    ```elixir
        iex(0)> some code
        ...(0)> more code
        result
    ```

    Just text

    ```elixir
        iex(0)> yet more code
        result
    ```
    """
    test "moduledoc with trailing code block" do
      mdoc = Extractly.moduledoc("Test.Support.DoctestModule", wrap_code_blocks: "elixir")

      assert mdoc == @expected
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
