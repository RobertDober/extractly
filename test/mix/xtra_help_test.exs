defmodule Mix.XtraHelpTest do
  use ExUnit.Case
  
  import ExUnit.CaptureIO

  test "prints help text to stderr" do
    stderr = capture_io(:stderr, fn ->
      Mix.Tasks.Xtra.Help.run([])
    end)
    assert Regex.match?(~r{### Usage:}, stderr)
  end
end
