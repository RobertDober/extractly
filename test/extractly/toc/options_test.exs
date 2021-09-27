defmodule Test.Extractly.Toc.OptionsTest do
  use ExUnit.Case

  alias Extractly.Toc.Options

  describe "to_string is just inspect" do
    test "default" do
      o = Options.new!

      assert Options.to_string(o) == inspect(o)
    end

    test "some values" do
      o = Options.new!(min_level: 2, type: :ol, format: :html)

      assert Options.to_string(o) == inspect(o)
    end
  end

  @default_options_str "%Extractly.Toc.Options{format: :markdown, gh_links: false, max_level: 7, min_level: 1, remove_gaps: false, start: 1, type: :ul}"
  describe "from_string needs some parsing" do
    test "default" do
      options = Options.from_string!(@default_options_str)

      assert options == Options.new!
    end
    test "with some different values" do
      options = Options.new!(type: :ol, start: 5, format: :ast)
      repr    = Options.to_string(options)

      assert Options.from_string!(repr) == options
    end
    test "illegal boolean" do
      input =
      "%Extractly.Toc.Options{format: :markdown, gh_links: falsy}"
      assert_raise RuntimeError, "Illegal boolean value falsy", fn ->
        Options.from_string!(input)
      end
    end
    test "illegal integer" do
      input =
      "%Extractly.Toc.Options{format: :markdown, start: 1a, gh_links: falsy}"
      assert_raise RuntimeError, "Illegal integer value 1a", fn ->
        Options.from_string!(input)
      end
    end
    test "bad representation" do
      input =
      "{format: :markdown, start: 1, gh_links: false"
      assert_raise RuntimeError, "Illegal Options representation: {format: :markdown, start: 1, gh_links: false", fn ->
        Options.from_string!(input)
      end
    end
  end
end
