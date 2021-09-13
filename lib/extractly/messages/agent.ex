defmodule Extractly.Messages.Agent do
  use Agent

  @moduledoc """
  An agent that collects messages from all templates
  """

  def start_link do
    Agent.start_link(fn -> [] end, name: __MODULE__)
  end

  def add_message(message) do
    Agent.update(__MODULE__, &[message|&1])
  end

  def messages do
    Agent.get_and_update(__MODULE__, &{ &1, []})
  end
end
