defmodule QueryTest do
  use ExUnit.Case

  setup do
    {:ok,
     graph:
       DottGraph.new("test_graph", [
         [:anna, :knows, :camille]
       ])}
  end

  describe "Patterns using literals" do
    test "pattern with subject literal", %{graph: graph} do
      assert {:ok, [%Types.Triples{subject: :anna, predicate: :knows, object: :camille}]} =
               Query.query(graph, [:anna, :knows, :camille])
    end
  end
end
