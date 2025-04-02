defmodule Errors.NodeMissingError do
  @moduledoc """
  Error raised when attempting to find a node in a graph and it is not found.
  """
  defexception message: "Node not found in graph."
end
