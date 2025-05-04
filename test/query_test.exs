defmodule QueryTest do
  use ExUnit.Case

  setup do
    {:ok,
     graph:
       DottGraph.new("test_graph", [
         [:anna, :knows, :camille],
         [:camille, :knows, :anna]
       ])}
  end

  describe "Patterns using literals" do
    @tag :skip
    test "pattern with subject literal", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille},
                %Types.Triples{subject: :camille, predicate: :knows, object: :anna}
              ]} ==
               Query.query(graph, [:anna, :knows, :camille])
    end
  end

  describe "Patterns using the variable type and literals" do
    test "use two blanks and a literal", %{graph: graph} do
      assert {:ok, [%Types.Triples{subject: :anna, predicate: :knows, object: :camille}]} =
               Query.query(graph, [:anna, :__var, :__var])
    end
  end
end
