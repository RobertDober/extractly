defmodule Test.Extractly.MessagesTest do
  use ExUnit.Case

  alias Extractly.Messages, as: M

  describe "reading empties" do
    test "empty means empty, right Theresa?" do
      M.messages
      assert M.messages == []
    end
  end

  describe "filtering of messages" do
    setup :set_messages
    test "at first, only at first" do
      assert M.messages == [{:warning, "warning"}, {:error, "error 1"}, {:info, "info"}, {:error, "error 2"}]
      assert M.messages == []
    end
    test "at first, only at first (looking for all)" do
      assert M.messages == [{:warning, "warning"}, {:error, "error 1"}, {:info, "info"}, {:error, "error 2"}]
      assert M.messages(:debug) == []
    end
    test "at first, only at first (seeing all)" do
      assert M.messages(:debug) == [{:warning, "warning"}, {:error, "error 1"}, {:info, "info"}, {:debug, "debug 1"}, {:error, "error 2"}, {:debug, "debug 2"}]
      assert M.messages(:debug) == []
    end
  end

  def set_messages(_context) do
    M.messages # clear from other runs
    M.add_warning("warning")
    M.add_error("error 1")
    M.add_info("info")
    M.add_debug("debug 1")
    M.add_error("error 2")
    M.add_debug("debug 2")
    :ok
  end
end
