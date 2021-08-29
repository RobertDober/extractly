defmodule Extractly.FunctiondocTest do
  use ExUnit.Case

  import Support.Random, only: [random_string: 0]

  describe "no such doc or function" do
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

  describe "found for public functions" do
    test "finds it for a public function" do
      fdoc = Extractly.functiondoc "Support.Module1.hello/0"

      assert fdoc == "Functiondoc of Module1.hello\n"
    end
  end

  describe "multiple functions" do
    test "can return two" do
      fdoc = Extractly.functiondoc ["Support.Module2.function/0", "Support.Module1.hello/0"]

      assert fdoc == "A function\nA nice one\nFunctiondoc of Module1.hello\n"
    end

    test "two of same module can be simplified" do
      fdoc = Extractly.functiondoc ["hello/0", "other/0"], module: "Support.Module1"

      assert fdoc == "Functiondoc of Module1.hello\nOther functiondoc\n"
    end

    test "we can use the function name as headlines" do
      fdoc = Extractly.functiondoc( ["hello/0", "other/0"], module: "Support.Module1", headline: 4 )

      assert fdoc == "#### Support.Module1.hello/0\n\nFunctiondoc of Module1.hello\n#### Support.Module1.other/0\n\nOther functiondoc\n"
    end

    test "and we can use :all to get all public functions" do
      fdoc = Extractly.functiondoc( :all, module: "Support.Module1", headline: 4 )

      assert fdoc == "#### Support.Module1.hello/0\n\nFunctiondoc of Module1.hello\n#### Support.Module1.other/0\n\nOther functiondoc\n"
    end
  end

  describe "no such module" do
    test "and we can use :all to get... an error message " do
      fdoc = Extractly.functiondoc( :all, module: "Support.DoesNotExist", headline: 4 )

      assert fdoc == "<!-- ERROR cannot load module `Elixir.Support.DoesNotExist' -->"
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
