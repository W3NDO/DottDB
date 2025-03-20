defmodule DottGraph do
  @moduledoc """
  Defines types and behaviours for the graph object
  """

  @type t :: %__MODULE__{
          name: String.t(),
          nodes: list(DottNode.t()),
          edges: list(DottEdge.t())
        }

  @enforce_keys [:nodes, :edges]
  defstruct name: nil,
            nodes: [],
            edges: []

  @spec new(name :: String.t(), nodes :: list(DottNode.t()), edges :: list(DottEdge.t())) ::
          struct()
  def new(name, nodes, edges) when is_nil(name) or is_nil(nodes) or is_nil(edges) do
    raise ArgumentError, "Graph name, nodes list, and edge list must be present"
  end

  def new(graph_name, nodes, edges) do
    dott_nodes =
      nodes
      |> Enum.map(fn [node_label, attributes] ->
        cond do
          Enum.empty?(attributes) ->
            DottNode.new(node_label)

          true ->
            DottNode.new(node_label, attributes)
        end
      end)

    dott_edges =
      edges
      |> Enum.map(fn
        [edge_label, src_node, dest_node] ->
          DottEdge.new(edge_label, src_node, dest_node)

        [edge_label, src_node, dest_node, attributes] ->
          DottEdge.new(edge_label, src_node, dest_node, attributes)

        [edge_label, src_node, dest_node, attributes, type] ->
          DottEdge.new(edge_label, src_node, dest_node, attributes, type)
      end)

    %DottGraph{name: graph_name, nodes: dott_nodes, edges: dott_edges}
  end

  def info(graph) do
    %{nodes: length(graph.nodes), edges: length(graph.edges)}
  end

  def graph_from_edge_list(graph_name, edge_list, type) do
    dott_edges =
      edge_list
      |> Enum.map(fn
        [edge_label, src_node, dest_node] ->
          DottEdge.new(edge_label, src_node, dest_node, %{}, type)
      end)

    dott_nodes =
      edge_list
      |> Enum.map(fn
        [_edge_label, node_label_1, node_label_2] ->
          [node_label_1, node_label_2]
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> Enum.map(fn label -> DottNode.new(label) end)

    %DottGraph{name: graph_name, nodes: dott_nodes, edges: dott_edges}
  end

  def new_from_file(graph_name, file_path) do
    File
  end
end
