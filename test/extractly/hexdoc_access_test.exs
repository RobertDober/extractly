defmodule ExtractlyTest do
  use ExUnit.Case

  import Support.Random, only: [random_string: 0]

  describe "module doc" do
    test "finds it if present" do
      mdoc = Extractly.moduledoc "Support.Module1"

      assert mdoc == "Moduledoc of Module1\n"
    end

    test "does not find it if module is absent" do
      mdoc = Extractly.moduledoc "Support.M#{random_string()}"

      assert mdoc == nil
    end

    test "does not find it if moduledoc is absent" do
      mdoc = Extractly.moduledoc "Support.Module2"

      assert mdoc == nil
    end
  end

  describe "macros" do
    test "docs are found too" do
      mdoc = Extractly.macrodoc "Support.Macro.i_am_a_macro/0"

      assert mdoc == "I am a macro"
    end

    test "unless they do not exist" do
      mdoc = Extractly.macrodoc "Support.Macro.but_i_am_not/1"

      assert mdoc == nil
    end
  end
end
