  defmodule Extractly.Toc.Options do
  defstruct gh_links: false,
    format: :markdown,
    min_level: 1,
    max_level: 7,
    remove_gaps: false,
    start: 1,
    type: :ul

  def new(from \\ []) do
    try do
      {:ok, struct!(__MODULE__, from)}
    rescue
      ke in KeyError -> {:error, "Unsupported option #{ke.key}"}
    end
  end
end
