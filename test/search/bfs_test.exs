defmodule Search.BfsTest do
  use ExUnit.Case

  describe "Raise if source or destination not found" do
    @graph %DottGraph{
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
    test "Source missing" do
      assert Search.Bfs.bfs_search(@graph, nil, "node_2") == "Source node not provided"
    end

    test "Destination missing" do
      assert Search.Bfs.bfs_search(@graph, "node_1", nil) == "Destination node not provided"
    end

    test "Source or Destination don't exist in the graph" do
      assert_raise(Errors.NodeMissingError, fn ->
        Search.Bfs.bfs_search(@graph, "node_3", "node_2")
      end)

      assert_raise(Errors.NodeMissingError, fn ->
        Search.Bfs.bfs_search(@graph, "node_1", "node_3")
      end)
    end
  end
end
