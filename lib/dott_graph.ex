defmodule DottGraph do
  @moduledoc """
  Defines types and behaviours for the graph object
  """
  alias Types.Triples
  # @filetypes ["csv", "json"]

  # @derive {Inspect, only: [:name, :nodes, :edges, :triples]}

  @type triple_arg :: {
          subject :: String.t() | atom(),
          predicate :: String.t() | atom(),
          object :: String.t() | atom()
        }

  @type t :: %__MODULE__{
          name: String.t(),
          nodes: list(DottNode.t()) | nil,
          edges: list(DottEdge.t()) | nil,
          triples: list(Triples.t()) | nil,
          meta: Enumerable.t()
        }

  @enforce_keys [:nodes, :edges, :triples]
  defstruct name: nil,
            nodes: [],
            edges: [],
            triples: [],
            meta: %{node_count: 0, edge_count: 0}

  @doc """
    DottGraph.new/2 will take in a graph name and a triple or a list of triples and return a graph with those triples.

    ## Examples

    iex> DottGraph.new(
    ...>      "test graph",
    ...>      [:alice, :knows, :bob]
    ...>    )

    %DottGraph{
      name: "test graph",
      triples: [%Types.Triples{subject: :alice, predicate: :knows, object: :bob}],
      nodes: [],
      edges: []
    }

  """
  @spec new(name :: String.t(), triples :: list(triple_arg)) :: %DottGraph{}

  def new(name, [[subject, predicate, object] | rest_of_triples]) do
    temp_graph = %__MODULE__{
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

    temp_graph
    |> add_triples(rest_of_triples)
  end

  def new(name, [subject, predicate, object]) do
    temp_graph = %__MODULE__{
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

    temp_graph |> get_nodes_from_triples |> get_edges_from_triples()
  end

  @spec new(name :: String.t(), nodes :: list(DottNode.t()), edges :: list(DottEdge.t())) ::
          %DottGraph{}
  def new(name, nodes, edges) when is_nil(name) or is_nil(nodes) or is_nil(edges) do
    raise ArgumentError, "Graph name, nodes list, and edge list must be present"
  end

  @doc """
    Creates a new Graph object. Accepts a graph name, node list and edge list

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
    graph = %__MODULE__{name: graph_name, nodes: [], edges: [], triples: []}

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

    Enum.each(dott_nodes, fn node -> add_node(graph, node) end)

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

    Enum.each(dott_edges, fn edge -> add_edge(graph, edge) end)

    temp_graph = %DottGraph{name: graph_name, nodes: dott_nodes, edges: dott_edges, triples: []}
    triples = get_triples(temp_graph)

    %DottGraph{name: graph_name, nodes: dott_nodes, edges: dott_edges, triples: triples}
    # |> set_node_count(length(dott_nodes))
    # |> set_edge_count(length(dott_edges))
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

  @doc """
    Insert a node into the graph object
  """
  @spec add_node(graph :: t(), node :: DottNode.t()) :: t()
  def add_node(graph, node) do
    new_node_count = graph.meta.node_count + 1
    node = %DottNode{node | id: new_node_count}

    %__MODULE__{
      graph
      | nodes: [node | graph.nodes],
        meta: %{graph.meta | node_count: new_node_count}
    }
  end

  @doc """
    Insert an edge into the graph object
  """
  @spec add_edge(graph :: t(), edge :: DottEdge.t()) :: t()
  def add_edge(graph, edge) do
    new_edge_count = graph.meta.edge_count + 1
    edge = %DottEdge{edge | id: new_edge_count}

    %__MODULE__{
      graph
      | edges: [edge | graph.edges],
        meta: %{graph.meta | edge_count: new_edge_count}
    }
  end

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

    temp_graph = %DottGraph{name: graph_name, nodes: dott_nodes, edges: dott_edges, triples: []}

    triples = get_triples(temp_graph)

    %DottGraph{name: graph_name, nodes: dott_nodes, edges: dott_edges, triples: triples}
  end

  @doc """
    Add a single triple to the triples list in the graph struct
  """
  defp add_triple(graph, [subject, predicate, object]) do
    %DottGraph{
      graph
      | triples: [
          %Triples{subject: subject, predicate: predicate, object: object} | graph.triples
        ]
    }
  end

  @spec add_triples(graph :: %DottGraph{}, triples :: list(triple_arg())) :: t()
  @doc """
  This function will add triples. You can pass in a list of triples or just one triple.

    ## Examples

    iex> DottGraph.add_triples(%DottGraph{
    ...>      name: "test graph",
    ...>      triples: [%Types.Triples{subject: :alice, predicate: :knows, object: :bob}],
    ...>      nodes: [],
    ...>      edges: []
    ...>    }, [:bob, :knows, :alice])

    %DottGraph{
      name: "test graph",
      triples: [
              %Types.Triples{subject: :alice, predicate: :knows, object: :bob},
              %Types.Triples{subject: :bob, predicate: :knows, object: :alice}
      ],
      nodes: [],
      edges: []
    }


  """

  def add_triples(graph, []) do
    graph
    |> get_nodes_from_triples()
    |> get_edges_from_triples()
  end

  # expected 2nd arg -> [[:anne, :knows, :camille], [:camille, :knows, :anne]]
  def add_triples(graph, [[s, p, o] | rest_of_triples]) do
    graph
    |> add_triple([s, p, o])
    |> add_triples(rest_of_triples)
  end

  # expected 2nd arg -> [:anne, :knows, :camille]
  def add_triples(graph, [subject, predicate, object]) do
    graph
    |> add_triple([subject, predicate, object])
    |> add_triples([])
  end

  @doc """
  Add nodes to the graph object from the triples in the graph object.
  """
  @spec get_nodes_from_triples(graph :: t()) :: t()
  def get_nodes_from_triples(graph) do
    {new_nodes, node_count} =
      Enum.map(graph.triples, fn %Triples{subject: s, predicate: _p, object: o} ->
        [s, o]
      end)
      |> List.flatten()
      |> Enum.uniq()
      |> then(fn node_labels ->
        node_count = length(node_labels) + get_node_count(graph)

        new_nodes =
          node_labels
          |> Enum.map(&DottNode.new/1)
          |> Enum.with_index(get_node_count(graph) + 1)
          |> Enum.map(fn {node, idx} -> DottNode.add_idx(node, idx) end)

        {new_nodes, node_count}
      end)

    case graph.triples do
      [] ->
        %__MODULE__{graph | nodes: new_nodes}

      _ ->
        %__MODULE__{graph | nodes: graph.nodes ++ new_nodes}
        |> set_node_count(node_count)
    end
  end

  @spec get_edges_from_triples(graph :: t()) :: t()
  def get_edges_from_triples(graph) do
    {new_edges, new_edge_count} =
      Enum.map(graph.triples, fn %Triples{subject: s, predicate: p, object: o} ->
        [s, p, o]
      end)
      |> Enum.map(fn [ts, tp, to] -> DottEdge.new(tp, ts, to) end)
      |> Enum.reject(fn %DottEdge{label: label, src_node_label: src, dest_node_label: dest} ->
        Enum.map(graph.edges, fn %DottEdge{
                                   label: existing_label,
                                   src_node_label: existing_src,
                                   dest_node_label: existing_dest
                                 } ->
          [existing_label, existing_src, existing_dest]
        end)
        |> Enum.member?([label, src, dest])
      end)
      |> then(fn edges ->
        new_edge_count = length(edges) + get_edge_count(graph)

        new_edges =
          edges
          |> Enum.with_index(get_edge_count(graph) + 1)
          |> Enum.map(fn {edge, idx} -> DottEdge.add_idx(edge, idx) end)

        {new_edges, new_edge_count}
      end)

    %__MODULE__{graph | edges: graph.edges ++ new_edges}
    |> set_edge_count(new_edge_count)
  end

  @spec get_triples(graph :: t()) :: list(Triples.t())
  def get_triples(graph) do
    cond do
      graph.edges != [] ->
        Enum.map(graph.edges, fn %DottEdge{label: p, src_node_label: s, dest_node_label: o} ->
          %Triples{predicate: p, subject: s, object: o}
        end)
    end
  end

  @doc """
  Returns the number of nodes in the graph
  """
  @spec get_node_count(graph :: t()) :: integer()
  def get_node_count(graph) do
    graph.meta.node_count
  end

  @doc """
  Returns the number of edges in the graph
  """
  @spec get_edge_count(graph :: t()) :: integer()
  def get_edge_count(graph) do
    graph.meta.edge_count
  end

  @doc """
  Updates the node count in the graph
  """
  @spec set_node_count(graph :: t(), count :: integer()) :: t()
  def set_node_count(graph, new_count) do
    %__MODULE__{graph | meta: %{graph.meta | node_count: new_count}}
  end

  @doc """
  Updates the edge count in the graph
  """
  @spec set_edge_count(graph :: t(), count :: integer()) :: t()
  def set_edge_count(graph, new_count) do
    %__MODULE__{graph | meta: %{graph.meta | edge_count: new_count}}
  end
end
