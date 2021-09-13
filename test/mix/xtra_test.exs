defmodule Mix.XtraTest do
  use ExUnit.Case

  import ExUnit.CaptureIO
  import Support.Random, only: [random_string: 0]

  describe "errors in arguments" do
    test "illegal options are detected" do
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run(~w{--hello})
      end)
      assert Regex.match?(~r{ERROR: Illegal arguments}, stderr)
    end
  end

  describe "informative options" do
    test "version prints semantic version to stdout" do
      stdout = capture_io( fn ->
        Mix.Tasks.Xtra.run(~w{--version})
      end)
      assert Regex.match?( ~r{\A\d+\.\d+\.\d+}, stdout)
    end
    test "prints help text to stdout" do
      stdout = capture_io(fn ->
        Mix.Tasks.Xtra.run(~w{--help})
      end)
      assert Regex.match?( ~r{mix xtra}, stdout)
    end
  end

  describe "dynamic error" do
    test "template does not exist" do
      phantasy = random_string()
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run([phantasy])
      end)
      assert Regex.match?(~r{Template #{phantasy} does not exist}, stderr)
    end

    test "output file cannot be written" do
      phantasy = random_string()
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run(["--output", "#{phantasy}/xxx", Path.expand("test/fixtures/template.eex")])
      end)
      assert Regex.match?(~r{Cannot write to}, stderr)
    end

    test "spourious output files" do
      spourious = random_string()
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run(["--output", "#{random_string()}/xxx", Path.expand("test/fixtures/template.eex"), spourious])
      end)
      assert Regex.match?(~r{WARNING: Spourious templates \["#{spourious}"\]}, stderr)
    end
  end

  describe "capturing output from a complete example" do
    test "mix of errors (verbose)" do
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run(["--verbose", Path.expand("test/fixtures/mix_of_errors.eex")])
      end)
      expected = """
      *debug* -- moduledoc called for DoesNotExist []
      *error* -- module not found Elixir.DoesNotExist
      *debug* -- functiondoc called for all [module: "DoesNotExist"]
      *error* -- cannot load module `Elixir.DoesNotExist'
      *debug* -- functiondoc called for all [module: "Support.Module1"]
      """
      assert stderr == expected
    end
    test "mix of errors (normal)" do
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run([Path.expand("test/fixtures/mix_of_errors.eex")])
      end)
      expected = """
      *error* -- module not found Elixir.DoesNotExist
      *error* -- cannot load module `Elixir.DoesNotExist'
      """
      assert stderr == expected
    end
    test "mix of errors (quiet)" do
      stderr = capture_io(:stderr, fn ->
        Mix.Tasks.Xtra.run(["--quiet", Path.expand("test/fixtures/mix_of_errors.eex")])
      end)
      expected = """
      *error* -- module not found Elixir.DoesNotExist
      *error* -- cannot load module `Elixir.DoesNotExist'
      """
      assert stderr == expected
    end
  end

end
