defmodule Extractly.Messages do
  @moduledoc """
  Implementation of the BL around the message collecting agent Extractly.Messages.Agent
  """
  alias Extractly.Messages.Agent, as: A

  def add_debug(debug_message), do: A.add_message({:debug, debug_message})
  def add_error(error_message), do: A.add_message({:error, error_message})
  def add_info(info_message), do: A.add_message({:info, info_message})
  def add_warning(warning_message), do: A.add_message({:warning, warning_message})

  @severities %{ debug: 4, info: 3, warning: 2, error: 1 }

  def messages(severity \\ :info)
  def messages(severity) do
    severity_ = Map.fetch!(@severities, severity)
    _filter_messages(A.messages, severity_, [])
  end

  defp _filter_messages(messages, severity, result)
  defp _filter_messages([], _, result), do: result
  defp _filter_messages([message|rest], severity, result) do
    if _severe_enough_to_be_retained?(message, severity) do
      _filter_messages(rest, severity, [message|result])
    else
      _filter_messages(rest, severity, result)
    end
  end

  defp _severe_enough_to_be_retained?({severity, _}, requested_severity) do
    Map.fetch!(@severities, severity) <= requested_severity
  end

end
