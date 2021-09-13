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
      fdoc = functiondoc(:all, module: "Test.Support.DoctestModule")

      assert fdoc == @expected
    end

    test "with explicit" do
      fdoc = functiondoc("Test.Support.DoctestModule.fun/0")

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
      mdoc = moduledoc("Test.Support.DoctestModule")

      assert mdoc == @expected
    end
  end

  defp functiondoc(fun, module: mod) do
    [ok: result] = Extractly.functiondoc(fun, module: mod, wrap_code_blocks: "elixir")
    result
  end
  defp functiondoc(desc) do
    [ok: result] = Extractly.functiondoc(desc, wrap_code_blocks: "elixir")
    result
  end

  defp moduledoc(desc) do
    {:ok, result} = Extractly.moduledoc(desc, wrap_code_blocks: "elixir")
    result
  end
end
#  SPDX-License-Identifier: Apache-2.0
