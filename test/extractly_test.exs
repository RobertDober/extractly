defmodule ExtractlyTest do
  use ExUnit.Case

  import Support.Random, only: [random_string: 0]

  doctest Extractly


  describe "function doc" do 

    test "finds it for a public function" do
      fdoc = Extractly.functiondoc "Support.Module1.hello/0"

      assert fdoc == "Functiondoc of Module1.hello\n"
    end

    test "undocumented public function" do
      fdoc = Extractly.functiondoc "Support.Module1.sample/0"

      assert fdoc == nil
    end

    test "public function missing @doc" do
      fdoc = Extractly.functiondoc "Support.Module1.missing/1"

      assert fdoc == nil
    end

    test "private function" do
      fdoc = Extractly.functiondoc "Support.Module1.add/2"

      assert fdoc == nil
    end

    test "unexisting function" do
      fdoc = Extractly.functiondoc "Support.Module1.#{random_string()}/1"

      assert fdoc == nil
    end
    
  end

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

end
