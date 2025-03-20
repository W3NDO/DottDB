defmodule DottNodeTest do
  use ExUnit.Case
  doctest DottNode

  test "creates a new node" do
    assert %DottNode{label: "node", attributes: %{}, meta: %{read: 0, write: 0}} ==
             DottNode.new("node")
  end

  test "Raises an error, if no label is provided as the node label" do
    assert_raise(ArgumentError, fn -> DottNode.new(nil) end)
  end

  test "takes in extra attributes if they are provided" do
    assert %DottNode{
             label: "node",
             attributes: %{attr1: "an attribute"},
             meta: %{read: 0, write: 0}
           } ==
             DottNode.new("node", %{attr1: "an attribute"})
  end
end
