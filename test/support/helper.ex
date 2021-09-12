defmodule Test.Support.Helper do

  # extract macrodoc from the :ok case
  def macrodoc(name, opts \\ []) do
    {:ok, result} = Extractly.macrodoc(name, opts)
    result
  end

  # extract moduledoc from the :ok case
  def moduledoc(name, opts \\ []) do
    {:ok, result} = Extractly.moduledoc(name, opts)
    result
  end

end
