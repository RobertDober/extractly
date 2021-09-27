defmodule Extractly.Toc.Renderer.AstRenderer do

  @doc ~S"""
  Transform a normalized tuple list (that is a list of tuples of the form {n, text})
  in which there exists an entry of the form {m, text} for all m betwenn min(n) and
  max(n)

  Two formats are supported

  ### The _simple_ `PushList`

  where the tuple list is transformed into a linear structural
  representation of the different levels by representing opening and closing brackets by
  the symbols `:open` and  `:close`

      iex(1)> render_push_list([{1, "I"}, {3, "I - (i)"}, {1, "II"}, {2, "II 1"}])
      ["I", :open, :open, "I - (i)", :close, :close, "II", :open, "II 1", :close]

  This format is ideal to be transformed into, e.g. an HTML representation

  """
  def render_push_list(normalized_tuples, options \\ [])
  def render_push_list(normalized_tuples, _options), do: _render_push_list(normalized_tuples, {1, []})


  @doc ~S"""
  ### A structural nested array (extracted from the `PushList`)

      iex(2)> render_ast([{1, "I"}, {3, "I - (i)"}, {1, "II"}, {2, "II 1"}])
      ["I", [["I - (i)"]], "II", ["II 1"]]
  """
  def render_ast(normalized_tuples, options \\ [])
  def render_ast(normalized_tuples, _options), do:
    normalized_tuples
    |> _render_push_list({1, []})
    # |> IO.inspect
    |> _make_tree([])

  defp _add_closes_and_reverse(n, push_list)
  defp _add_closes_and_reverse(1, push_list), do: Enum.reverse(push_list)
  defp _add_closes_and_reverse(n, push_list), do: _add_closes_and_reverse(n-1, [:close|push_list])

  defp _render_push_list(tuples, result)
  defp _render_push_list([], {n, push_list}), do: _add_closes_and_reverse(n, push_list)
  defp _render_push_list([tuple|rest], result), do: _render_push_list(rest, _new_result(tuple, result))

  defp _make_tree(push_list, result)
  defp _make_tree([], result), do: Enum.reverse(result)
  defp _make_tree([:close|rest], result), do: _make_tree(rest, _up_and_reverse([[]|result]))
  defp _make_tree([head|rest], result), do: _make_tree(rest, [head|result])

  defp _new_result(tuple, result)
  defp _new_result({tlevel, text}, {clevel, result}) when tlevel == clevel, do: {clevel, [text|result]}
  defp _new_result({tlevel, text}, {clevel, result}) when tlevel > clevel do
    {tlevel, [text|_prepend(:open, tlevel-clevel, result)]}
  end
  defp _new_result({tlevel, text}, {clevel, result}) do
    {tlevel, [text|_prepend(:close, clevel-tlevel, result)]}
  end

  defp _prepend(sym, count, to)
  defp _prepend(_, 0, to), do: to
  defp _prepend(sym, n, to), do: _prepend(sym, n-1, [sym|to])

  defp _up_and_reverse(result)
  defp _up_and_reverse([head, :open|result]), do: [head|result]
  defp _up_and_reverse([head, text|result]), do: _up_and_reverse([[text|head]|result])
end
#  SPDX-License-Identifier: Apache-2.0
