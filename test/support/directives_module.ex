defmodule Test.Support.DirectivesModule do
  @doc """
  Some test
  <!-- %extractly%ignore_line%
  %extractly%ignore_line (not this one)
  """
  def fn1, do: "fn1"

  @doc """
  %extractly%stop_processing%
  """
  def fn2, do: "fn2"

  @doc """
  extractly%stop_processing%
  """
  def fn3, do: "fn3"

  @doc """
  Line 1
  some %extracly%suspend_processing% more%
  Ignored
  again %extracly%resume_processing%% second % is not good
  again %extracly%resume_processing% that is better
  Line 2
  %extractly%ignore_line% ----
  Line 3
  <!-- %extractly%stop_processing% -->
  Not contained anymore
  """
  def fn4, do: "fn4"
end
