defmodule DottGraph do
  @moduledoc """
  Defines types and behaviours for the graph object
  """

  @type t :: %__MODULE__{
          name: String.t(),
          nodes: Enumerable.t(),
          edges: Enumerable.t()
        }

  defstruct name: nil,
            nodes: [],
            edges: []

  @callback new(name :: String.t(), nodes :: Enumerable.t(), edges :: Enumerable.t()) :: struct()

  def new(nil, _nodes, _edges) do
    raise "Graph name must be present"
  end

  def new(_name, nil, _edges) do
    raise "Nodes list must be present"
  end

  def new(_name, _nodes, nil) do
    raise "Edge list must be present"
  end

  def new(graph_name, nodes, edges) do
    %DottGraph{name: graph_name, nodes: nodes, edges: edges}
  end
end
