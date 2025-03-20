defmodule DottGraphTest do
  use ExUnit.Case
  doctest DottGraph

  test "Creates a new DottGraph object" do
    assert %DottGraph{name: "New Graph", nodes: [], edges: []} ==
             DottGraph.new("New Graph", [], [])
  end

  test "Fails if graph name is not provided" do
    assert_raise(RuntimeError, fn -> DottGraph.new(nil, [], []) end)
  end

  test "Fails if nodes list is not provided" do
    assert_raise(RuntimeError, fn -> DottGraph.new("Graph Name", nil, []) end)
  end

  test "Fails if edge list is not provided" do
    assert_raise(RuntimeError, fn -> DottGraph.new("Graph Name", [], nil) end)
  end
end
