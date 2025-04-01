defmodule DottGraphTest do
  use ExUnit.Case
  doctest DottGraph

  describe "Building a graph object" do
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
               ]
             } == DottGraph.graph_from_edge_list("test graph", edge_list, :directed)
    end
  end
end
