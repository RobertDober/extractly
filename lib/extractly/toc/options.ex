defmodule Extractly.Toc.Options do
  defstruct gh_links: false,
    format: :markdown,
    min_level: 1,
    max_level: 7,
    type: :ul

  def new(from \\ []), do: struct(__MODULE__, from)
end
