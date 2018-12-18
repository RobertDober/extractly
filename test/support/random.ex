defmodule Support.Random do
  def random_string(length \\ 32) do
     :crypto.strong_rand_bytes(length) |> Base.encode32
  end
end
