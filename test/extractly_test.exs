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

    test "private function" do
      fdoc = Extractly.functiondoc "Support.Module1.add/2"

      assert fdoc == nil
    end

    test "unexisting function" do
      fdoc = Extractly.functiondoc "Support.Module1.#{random_string}/1"

      assert fdoc == nil
    end
    
  end
end
