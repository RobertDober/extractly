defmodule Extractly.ModuledocTest do
  use ExUnit.Case

  import Test.Support.Helper, only: [moduledoc: 1, moduledoc: 2]
  import Support.Random, only: [random_string: 0]

  describe "base cases" do
    test "w/o headline" do
      mdoc =  moduledoc "Support.Module1"

      assert mdoc == "Moduledoc of Module1\n"
    end

    test "with headline" do
      mdoc =  moduledoc "Support.Module1", headline: 1

      assert mdoc == "# Support.Module1\n\nModuledoc of Module1\n"
    end
  end

  describe "no such moduledoc" do
    test "no module" do
      mname = "Support.Module1.M#{random_string()}/1"
      mdoc = Extractly.moduledoc mname

      assert mdoc == {:error, "module not found Elixir.#{mname}"}
    end

    test "no moduledoc" do
      mdoc = Extractly.moduledoc "Support.Module2"

      assert mdoc ==  {:error, "module Support.Module2 does not have a moduledoc"}
    end

    test "moduledoc is false" do
      mdoc = Extractly.moduledoc "Support.Module3"

      assert mdoc ==  {:error, "module Support.Module3 does not have a moduledoc"}
    end
  end

  describe "headline and include" do
    test "include functiondocs" do
      mdoc = Extractly.moduledoc "Support.Module1", include: :all

      assert mdoc ==
        [
          ok: "Moduledoc of Module1\n",
          ok: "Functiondoc of Module1.hello\n",
          ok: "Other functiondoc\n",
          ok: "Macro of Module1\n"
        ]
    end
    test "must not use a different keyword" do
      mdoc = Extractly.moduledoc "Support.Module1", include: :some

      assert mdoc ==
        [
          ok: "Moduledoc of Module1\n",
          error: "Illegal value some for include: keyword in moduledoc for module Support.Module1, legal values are nil and :all",
        ]
    end
  end

end
#  SPDX-License-Identifier: Apache-2.0
