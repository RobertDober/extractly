defmodule Extractly.Toc.Renderer.AstRenderer do
  @moduledoc false

  # works on normalized tuples
  def render_ast(normalized_tuples), do:
    normalized_tuples
    |> _make_push_list({1, []})
    # |> IO.inspect
    |> _make_tree([])

  defp _add_ups_and_reverse(n, push_list)
  defp _add_ups_and_reverse(1, push_list), do: Enum.reverse(push_list)
  defp _add_ups_and_reverse(n, push_list), do: _add_ups_and_reverse(n-1, [:up|push_list])

  defp _make_push_list(tuples, result)
  defp _make_push_list([], {n, push_list}), do: _add_ups_and_reverse(n, push_list)
  defp _make_push_list([tuple|rest], result), do: _make_push_list(rest, _new_result(tuple, result))

  defp _make_tree(push_list, result)
  defp _make_tree([], result), do: Enum.reverse(result)
  defp _make_tree([:up|rest], result), do: _make_tree(rest, _up_and_reverse([[]|result]))
  defp _make_tree([head|rest], result), do: _make_tree(rest, [head|result])

  defp _new_result(tuple, result)
  defp _new_result({tlevel, text}, {clevel, result}) when tlevel == clevel, do: {clevel, [text|result]}
  defp _new_result({tlevel, text}, {clevel, result}) when tlevel > clevel do
    {tlevel, [text|_prepend(:down, tlevel-clevel, result)]}
  end
  defp _new_result({tlevel, text}, {clevel, result}) do
    {tlevel, [text|_prepend(:up, clevel-tlevel, result)]}
  end

  defp _prepend(sym, count, to)
  defp _prepend(_, 0, to), do: to
  defp _prepend(sym, n, to), do: _prepend(sym, n-1, [sym|to])

  defp _up_and_reverse(result)
  defp _up_and_reverse([head, :down|result]), do: [head|result]
  defp _up_and_reverse([head, text|result]), do: _up_and_reverse([[text|head]|result])
end
