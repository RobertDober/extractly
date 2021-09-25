defmodule Test.Extractly.Tools.LinesFromSourceTest do
  use ExUnit.Case

  import Extractly.Tools, only: [lines_from_source: 1]

  @short "test/fixtures/toc-short.md"
  test "from file name" do
    assert lines_from_source(@short) == expected_lines(@short)
  end

  test "from stream" do
    stream = @short |> File.stream!([:utf8], :line)
    assert lines_from_source(stream) == expected_lines(@short)
  end

  test "from list" do
    list = @short |> File.stream!([:utf8], :line) |> Enum.to_list
    assert lines_from_source(list) == expected_lines(@short)
  end

  defp expected_lines(filename),
    do:
      filename
      |> File.stream!([:utf8], :line)
      |> Enum.to_list()
end
