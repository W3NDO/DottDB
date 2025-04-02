defmodule Search.Bfs do
  def bfs_search(_graph_name, nil, _destination), do: "Source node not provided"
  def bfs_search(_graph_name, _source, nil), do: "Destination node not provided"
  def bfs_search(nil, _source, _destination), do: "Graph not provided"

  @spec bfs_search(graph :: DottGraph.t(), source :: String.t(), destination :: String.t()) ::
          list(Enumerable.t())
  def bfs_search(graph, source, destination) do

    node_labels = Enum.map(graph.nodes, & &1.label)
    unless source in node_labels,
      do: raise Errors.NodeMissingError
    unless destination in node_labels,
      do: raise Errors.NodeMissingError
  end
end
