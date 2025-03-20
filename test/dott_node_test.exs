defmodule DottNodeTest do
  use ExUnit.Case
  doctest DottNode

  test "creates a new node" do
    assert %DottNode{label: "node", attributes: %{}} == DottNode.new("node")
  end

  test "Raises an error, if no label is provided as the node label" do
    assert_raise(RuntimeError, fn -> DottNode.new(nil) end)
  end

  test "takes in extra attributes if they are provided" do
    assert %DottNode{label: "node", attributes: %{attr1: "an attribute"}} ==
             DottNode.new("node", %{attr1: "an attribute"})
  end
end
