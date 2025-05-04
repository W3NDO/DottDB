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
    test "pattern with subject literal", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} ==
               Query.query(graph, [:anna, :knows, :camille])
    end
  end

  describe "Patterns using the variable type and literals" do
    test "use two blanks and a literal", %{graph: graph} do
      assert {:ok, [%Types.Triples{subject: :anna, predicate: :knows, object: :camille}]} =
               Query.query(graph, [:anna, :__var, :__var])
    end

    test "use no literals and blanks only", %{graph: graph} do
      assert {:ok,
      [
        %Types.Triples{subject: :camille, predicate: :knows, object: :anna},
        %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
      ]} = Query.query(graph, [:__var, :__var, :__var])
    end

    test "use one blank and 2 literals", %{graph: graph} do
      assert {:ok,
      [
        %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
      ]} = Query.query(graph, [:__var, :knows, :camille])
    end
  end
end
