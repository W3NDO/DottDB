defmodule DottEdgeTest do
  use ExUnit.Case
  doctest DottEdge

  test "creates a new edge" do
    assert %DottEdge{
             label: "Edge",
             src_node_label: "first",
             dest_node_label: "second",
             attributes: %{},
             type: :undirected,
             meta: %{read: 0, write: 0}
           } ==
             DottEdge.new("Edge", "first", "second")
  end

  test "fails to create a new edge if label is not provided" do
    assert_raise(ArgumentError, fn -> DottEdge.new(nil, nil, nil, nil, nil) end)
  end
end
