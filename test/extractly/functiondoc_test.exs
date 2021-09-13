defmodule Extractly.FunctiondocTest do
  use ExUnit.Case

  import Support.Random, only: [random_string: 0]

  describe "no such doc or function" do
    test "undocumented public function" do
      fdoc = Extractly.functiondoc "Support.Module1.sample/0"

      assert fdoc == [{:error, "Function doc for function Support.Module1.sample/0 not found"}]
    end

    test "public function missing @doc" do
      fdoc = Extractly.functiondoc "Support.Module1.missing/1"

      assert fdoc == [{:error, "Function doc for function Support.Module1.missing/1 not found"}]
    end

    test "private function" do
      fdoc = Extractly.functiondoc "Support.Module1.add/2"

      assert fdoc == [{:error, "Function doc for function Support.Module1.add/2 not found"}]
    end

    test "unexisting function" do
      fname = "Support.Module1.#{random_string()}/1"
      fdoc = Extractly.functiondoc fname

      assert fdoc == [{:error, "Function doc for function #{fname} not found"}]
    end
  end

  describe "found for public functions" do
    test "finds it for a public function" do
      fdoc = Extractly.functiondoc "Support.Module1.hello/0"

      assert fdoc == [{:ok, "Functiondoc of Module1.hello\n"}]
    end
  end

  describe "multiple functions" do
    test "can return two" do
      fdoc = Extractly.functiondoc ["Support.Module2.function/0", "Support.Module1.hello/0"]
      expected =
        [ {:ok, "A function\nA nice one\n"}, {:ok, "Functiondoc of Module1.hello\n"}]

      assert fdoc == expected
    end

    test "two of same module can be simplified" do
      fdoc = Extractly.functiondoc ["hello/0", "other/0"], module: "Support.Module1"
      expected =
        [ {:ok, "Functiondoc of Module1.hello\n"}, {:ok, "Other functiondoc\n"} ]

      assert fdoc == expected
    end

    test "we can use the function name as headlines" do
      fdoc = Extractly.functiondoc( ["hello/0", "other/0"], module: "Support.Module1", headline: 4 )
      expected = [
        {:ok, "#### Support.Module1.hello/0\n\nFunctiondoc of Module1.hello\n"},
        {:ok, "#### Support.Module1.other/0\n\nOther functiondoc\n"},]

      assert fdoc == expected
    end

    test "and we can use :all to get all public functions" do
      fdoc = Extractly.functiondoc( :all, module: "Support.Module1", headline: 4 )
      expected = [
        {:ok, "#### Support.Module1.hello/0\n\nFunctiondoc of Module1.hello\n"},
        {:ok, "#### Support.Module1.other/0\n\nOther functiondoc\n"},]

      assert fdoc == expected
    end
  end

  describe "no such module" do
    test "and we can use :all to get... an error message " do
      fdoc = Extractly.functiondoc( :all, module: "Support.DoesNotExist", headline: 4 )

      assert fdoc == [error: "cannot load module `Elixir.Support.DoesNotExist'"]
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
