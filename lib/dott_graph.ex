defmodule DottGraph do
  @moduledoc """
  Defines types and behaviours for the graph object
  """
  alias Types.Triples
  # @filetypes ["csv", "json"]

  @type triple_arg :: {
          subject :: String.t() | atom(),
          predicate :: String.t() | atom(),
          object :: String.t() | atom()
        }

  @type t :: %__MODULE__{
          name: String.t(),
          nodes: list(DottNode.t()) | nil,
          edges: list(DottEdge.t()) | nil,
          triples: list(Triples.t()) | nil
        }

  @enforce_keys [:nodes, :edges]
  defstruct name: nil,
            nodes: [],
            edges: [],
            triples: []

  @doc """
    DottGraph.new/2 will take in a graph name and a triple or a list of triples and return a graph with those triples.

    ## Examples

    iex> DottGraph.new(
    ...>      "test graph",
    ...>      [:alice, :knows, :bob]
    ...>    )

    %DottGraph{
      name: "test graph",
      triples: [:alice, :knows, :bob],
      nodes: [],
      edges: []
    }

  """
  @spec new(name :: String.t(), triples :: list(triple_arg)) :: %DottGraph{}
  def new(name, [subject, predicate, object]) do
    %__MODULE__{
      name: name,
      triples: [
        %Types.Triples{
          subject: subject,
          predicate: predicate,
          object: object
        }
      ],
      nodes: [],
      edges: []
    }
  end

  def new(name, [[subject, predicate, object] | rest_of_triples]) do
    %__MODULE__{
      name: name,
      triples: [
        %Types.Triples{
          subject: subject,
          predicate: predicate,
          object: object
        }
      ],
      nodes: [],
      edges: []
    }
    |> add_triples(rest_of_triples)
  end

  @spec new(name :: String.t(), nodes :: list(DottNode.t()), edges :: list(DottEdge.t())) ::
          %DottGraph{}
  def new(name, nodes, edges) when is_nil(name) or is_nil(nodes) or is_nil(edges) do
    raise ArgumentError, "Graph name, nodes list, and edge list must be present"
  end

  @doc """
    Creates a new Graph object.

    Returns`%DottGraph{}`

    ## Examples

    iex> DottGraph.new(
    ...>      "test graph",
    ...>      [["node_1", %{attr1: "attr1"}], ["node_2", %{attr1: "attr1"}]],
    ...>      [
    ...>        ["edge_1", "node_1", "node_2", %{weight: 10}, :directed],
    ...>        ["edge_2", "node_2", "node_1", %{weight: 10}, :directed]
    ...>      ]
    ...>    )

    %DottGraph{
      edges: [
        %DottEdge{
          attributes: %{weight: 10},
          label: "edge_1",
          type: :directed,
          src_node_label: "node_1",
          dest_node_label: "node_2",
          meta: %{read: 0, write: 0}
        },
        %DottEdge{
          attributes: %{weight: 10},
          label: "edge_2",
          type: :directed,
          src_node_label: "node_2",
          dest_node_label: "node_1",
          meta: %{read: 0, write: 0}
        }
      ],
      name: "test graph",
      nodes: [
        %DottNode{
          attributes: %{attr1: "attr1"},
          label: "node_1",
          meta: %{read: 0, write: 0}
        },
        %DottNode{
          attributes: %{attr1: "attr1"},
          label: "node_2",
          meta: %{read: 0, write: 0}
        }
      ],
      triples: []
    }
  """
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

  @doc """
    Returns Info about the graph

    ## Examples
    iex> DottGraph.info(DottGraph.new(
    ...>    "test graph",
    ...>    [["node_1", %{attr1: "attr1"}], ["node_2", %{attr1: "attr1"}]],
    ...>    [
    ...>      ["edge_1", "node_1", "node_2", %{weight: 10}, :directed],
    ...>      ["edge_2", "node_2", "node_1", %{weight: 10}, :directed]
    ...>    ]
    ...>  ))

    %{nodes: 2, edges: 2}
  """

  def info(graph) do
    %{nodes: length(graph.nodes), edges: length(graph.edges)}
  end

  @doc """
    Builds a graph from an edge_list

    ## Examples

    iex> DottGraph.graph_from_edge_list("test graph", [["edge_1", "node_1", "node_2"], ["edge_2", "node_2", "node_1"]], :directed)

    %DottGraph{
          edges: [
            %DottEdge{
              attributes: %{},
              label: "edge_1",
              type: :directed,
              src_node_label: "node_1",
              dest_node_label: "node_2",
              meta: %{read: 0, write: 0}
            },
            %DottEdge{
              attributes: %{},
              label: "edge_2",
              type: :directed,
              src_node_label: "node_2",
              dest_node_label: "node_1",
              meta: %{read: 0, write: 0}
            }
          ],
          name: "test graph",
          nodes: [
            %DottNode{
              attributes: %{},
              label: "node_1",
              meta: %{read: 0, write: 0}
            },
            %DottNode{
              attributes: %{},
              label: "node_2",
              meta: %{read: 0, write: 0}
            }
          ]
        }
  """
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

  @spec add_triple(graph :: %DottGraph{}, triple :: triple_arg()) :: t()
  defp add_triple(graph, [subject, predicate, object]) do
    %DottGraph{
      graph
      | triples: [
          %Triples{subject: subject, predicate: predicate, object: object} | graph.triples
        ]
    }
  end

  @spec add_triples(graph :: %DottGraph{}, triples :: list(triple_arg())) :: t()
  def add_triples(graph, []) do
    graph
  end

  def add_triples(graph, [subject, predicate, object]) do
    add_triple(graph, [subject, predicate, object])
  end

  def add_triples(graph, [triple | rest_of_triples]) do
    graph
    |> add_triple(triple)
    |> add_triples(rest_of_triples)
  end
end
