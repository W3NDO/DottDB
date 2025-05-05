defmodule QueryTest do
  use ExUnit.Case

  setup do
    {:ok,
     graph:
       DottGraph.new("test_graph", [
         [:anna, :knows, :camille],
         [:camille, :knows, :anna],
         [:camille, :works_with, :bob],
         [:anna, :lives_with, :bob]
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
      assert {:ok,
              [
                %Types.Triples{object: :bob, predicate: :lives_with, subject: :anna},
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} =
               Query.query(graph, [:anna, :__var, :__var])
    end

    test "use no literals and blanks only", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{object: :bob, predicate: :lives_with, subject: :anna},
                %Types.Triples{object: :bob, predicate: :works_with, subject: :camille},
                %Types.Triples{object: :anna, predicate: :knows, subject: :camille},
                %Types.Triples{object: :camille, predicate: :knows, subject: :anna}
              ]} == Query.query(graph, [:__var1, :__var2, :__var3])
    end

    test "use one blank and 2 literals", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} = Query.query(graph, [:__var, :knows, :camille])
    end
  end

  describe "using the conjunction to match multiple patterns" do
    @tag :skip
    test "find who camille knows and who camille works with", %{graph: graph} do
      query = %Types.Query{
        find: [:__person_b, :__person_c],
        where: [
          [:camille, :knows, :__person_b],
          [:camille, :works_with, :__person_c]
        ]
      }

      assert {:ok,
              [
                %Types.Triples{subject: :camille, predicate: :knows, object: :anna},
                %Types.Triples{subject: :camille, predicate: :works_with, object: :bob}
              ]} = Query.query(graph, query)
    end
  end
end
