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
  some %extractly%suspend_processing% more%
  Ignored
  again %extractly%resume_processing%% second % is not good
  Ignored again
  again %extractly%resume_processing% that is better
  Line 2
  %extractly%ignore_line% ----
  Line 3
  <!-- %extractly%stop_processing% -->
  Not contained anymore
  """
  def fn4, do: "fn4"

  @doc """
  Forgetting resume
  %extractly%suspend_processing%
  ignored
  """
  def fn5, do: "fn5"
end
