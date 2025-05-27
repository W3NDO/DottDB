defmodule DottGraphTest do
  use ExUnit.Case
  doctest DottGraph
  alias DottGraph, as: Graph

  describe "Building a graph object with nodes & edges (new/3)" do
    test "Creates a new DottGraph object" do
      assert %DottGraph{
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
               triples: [
                 %Types.Triples{subject: "node_1", predicate: "edge_1", object: "node_2"},
                 %Types.Triples{subject: "node_2", predicate: "edge_2", object: "node_1"}
               ]
             } ==
               DottGraph.new(
                 "test graph",
                 [["node_1", %{attr1: "attr1"}], ["node_2", %{attr1: "attr1"}]],
                 [
                   ["edge_1", "node_1", "node_2", %{weight: 10}, :directed],
                   ["edge_2", "node_2", "node_1", %{weight: 10}, :directed]
                 ]
               )
    end

    test "Fails if graph name is not provided" do
      assert_raise(ArgumentError, fn -> DottGraph.new(nil, [%{label: "Anna"}], []) end)
    end

    test "Fails if nodes list is not provided" do
      assert_raise(ArgumentError, fn -> DottGraph.new("Graph Name", nil, []) end)
    end

    test "Fails if edge list is not provided" do
      assert_raise(ArgumentError, fn -> DottGraph.new("Graph Name", [], nil) end)
    end
  end

  describe "Gets information on the graph object" do
    test "Gets information on the graph" do
      assert %{nodes: 2, edges: 2} =
               DottGraph.info(
                 DottGraph.new(
                   "test graph",
                   [["node_1", %{attr1: "attr1"}], ["node_2", %{attr1: "attr1"}]],
                   [
                     ["edge_1", "node_1", "node_2", %{weight: 10}, :directed],
                     ["edge_2", "node_2", "node_1", %{weight: 10}, :directed]
                   ]
                 )
               )
    end
  end

  describe "Build a graph from an edge list" do
    test "Build graph from edge_list" do
      edge_list = [
        ["edge_1", "node_1", "node_2"],
        ["edge_2", "node_2", "node_1"]
      ]

      assert %DottGraph{
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
               ],
               triples: [
                 %Types.Triples{subject: "node_1", predicate: "edge_1", object: "node_2"},
                 %Types.Triples{subject: "node_2", predicate: "edge_2", object: "node_1"}
               ]
             } == DottGraph.graph_from_edge_list("test graph", edge_list, :directed)
    end
  end

  describe "new/2 :: Build a graph with triples" do
    test "accepts a list of triples and builds the graph with triples" do
      expected_triples = [
        %Types.Triples{subject: :alice, predicate: "knows", object: :bob},
        %Types.Triples{subject: :bob, predicate: :knows, object: :alice}
      ]

      graph = DottGraph.new("test graph", [[:alice, "knows", :bob], [:bob, :knows, :alice]])
      actual_triples = graph.triples

      assert true =
               Enum.all?(actual_triples, fn triple -> Enum.member?(expected_triples, triple) end)
    end

    test "Accepts a single triple and builds a graph with that as the triples" do
      assert %DottGraph{
               name: "test graph",
               triples: [
                 %Types.Triples{subject: :alice, predicate: :knows, object: :bob}
               ],
               nodes: [
                 %DottNode{attributes: %{}, label: :alice, id: 1, meta: %{read: 0, write: 0}},
                 %DottNode{attributes: %{}, label: :bob, id: 2, meta: %{read: 0, write: 0}}
               ],
               edges: [
                 %DottEdge{
                   id: 1,
                   attributes: %{},
                   label: :knows,
                   meta: %{read: 0, write: 0},
                   type: :undirected,
                   src_node_label: :alice,
                   dest_node_label: :bob
                 }
               ],
               meta: %{edge_count: 1, node_count: 2}
             } == DottGraph.new("test graph", [:alice, :knows, :bob])
    end

    test "Accept a list of triples and build nodes & edges from them & update the meta" do
      assert %DottGraph{
               edges: [
                 %DottEdge{
                   attributes: %{},
                   dest_node_label: :bob,
                   id: 1,
                   label: :lives_with,
                   meta: %{read: 0, write: 0},
                   src_node_label: :alice,
                   type: :undirected
                 },
                 %DottEdge{
                   attributes: %{},
                   id: 2,
                   label: :knows,
                   meta: %{read: 0, write: 0},
                   type: :undirected,
                   src_node_label: :bob,
                   dest_node_label: :alice
                 },
                 %DottEdge{
                   attributes: %{},
                   id: 3,
                   label: :knows,
                   meta: %{read: 0, write: 0},
                   type: :undirected,
                   src_node_label: :alice,
                   dest_node_label: :bob
                 }
               ],
               meta: %{edge_count: 3, node_count: 2},
               name: "test graph",
               nodes: [
                 %DottNode{label: :alice, attributes: %{}, id: 1, meta: %{read: 0, write: 0}},
                 %DottNode{label: :bob, attributes: %{}, id: 2, meta: %{read: 0, write: 0}}
               ],
               triples: [
                 %Types.Triples{object: :bob, predicate: :lives_with, subject: :alice},
                 %Types.Triples{subject: :bob, predicate: :knows, object: :alice},
                 %Types.Triples{subject: :alice, predicate: :knows, object: :bob}
               ]
             } ==
               DottGraph.new("test graph", [
                 [:alice, :knows, :bob],
                 [:bob, :knows, :alice],
                 [:alice, :lives_with, :bob]
               ])
    end
  end

  describe "Adding triples to the graph" do
    test "add_triples/2 with one set of triples" do
      graph = DottGraph.new("test graph", [:alice, :knows, :bob])

      expected_triples = [
        %Types.Triples{subject: :alice, predicate: :knows, object: :bob},
        %Types.Triples{subject: :bob, predicate: :knows, object: :alice}
      ]

      DottGraph.add_triples(graph, [:bob, :knows, :alice])
      actual_triples = graph.triples

      assert true =
               Enum.all?(actual_triples, fn triple -> Enum.member?(expected_triples, triple) end)
    end

    test "add_triples/2 with multiple set of triples" do
      graph = DottGraph.new("test graph", [:alice, :knows, :bob])

      expected_triples = [
        %Types.Triples{subject: :john, predicate: :knows, object: :alice},
        %Types.Triples{subject: :alice, predicate: :knows, object: :bob},
        %Types.Triples{subject: :bob, predicate: :knows, object: :alice}
      ]

      DottGraph.add_triples(graph, [[:bob, :knows, :alice], [:john, :knows, :alice]])
      actual_triples = graph.triples

      assert true =
               Enum.all?(actual_triples, fn triple -> Enum.member?(expected_triples, triple) end)
    end

    @tag :skip
    @doc """
    The idea here is that when you add a new node with a similar label as one that exists, we compare their info and save the more detailed one

    Further for edges, if we add an edge with a similar label, src and dest, then we update the edge type.
    """
    test "add_triples/2 with multiple sets of triples, similar node names and edge names" do
      graph =
        Graph.new("Uniqueness Graph", [
          [:anna, :knows, :camille],
          [:camille, :knows, :anna],
          [:anna, :lives_with, :camille]
        ])

      expected_triples = [
        %Types.Triples{subject: :anna, predicate: :knows, object: :camille},
        %Types.Triples{subject: :camille, predicate: :knows, object: :anna},
        %Types.Triples{subject: :anna, predicate: :works_for, object: :camille}
      ]
    end
  end
end
