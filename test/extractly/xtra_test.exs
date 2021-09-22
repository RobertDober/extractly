defmodule Test.Extractly.XtraTest do
  use ExUnit.Case

  doctest Extractly.Xtra, import: true

  alias Extractly.Xtra

  describe "output of errors" do
    test "one fdoc is found the other not" do
      result = Xtra.functiondoc(["Support.Module2.function/0", "Support.Module2.no_function/0"])
      expected = "A function\nA nice one\n"

      assert result == expected

    end
  end

  describe "delegation to version" do
    test "version" do
      assert Xtra.version
    end
  end
end
