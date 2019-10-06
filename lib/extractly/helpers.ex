defmodule Extractly.Helpers do
  @moduledoc false

  def fdoc_headline(name, opts) do
    case Keyword.get(opts, :headline) do
      level when is_number(level) -> _fdoc_headline(name, level)
      _                             -> ""
    end
  end



  defp _fdoc_headline(name, level) do
    ( Stream.cycle(~w{#})
      |> Enum.take(level)
      |> Enum.join ) <> " #{name}\n\n"
  end
end
