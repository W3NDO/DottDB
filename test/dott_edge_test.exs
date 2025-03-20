defmodule DottEdgeTest do
  use ExUnit.Case
  doctest DottEdge

  test "creates a new edge" do
    assert %DottEdge{label: "Edge", nodes: [], attributes: %{}, type: nil} ==
             DottEdge.new("Edge", [])
  end

  test "fails to create a new edge if label is not provided" do
    assert_raise(RuntimeError, fn -> DottEdge.new(nil, []) end)
  end
end
