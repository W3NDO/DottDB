defmodule QueryEngineTest do
  use ExUnit.Case
  alias Types.Query

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

  describe "Queries using patterns" do
    test "pattern with subject literal", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} ==
               QueryEngine.query(graph, [:anna, :knows, :camille])
    end

    test "use two blanks and a literal", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{object: :bob, predicate: :lives_with, subject: :anna},
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} ==
               QueryEngine.query(graph, [:anna, :__var, :__var])
    end

    test "use no literals and blanks only", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{object: :bob, predicate: :lives_with, subject: :anna},
                %Types.Triples{object: :bob, predicate: :works_with, subject: :camille},
                %Types.Triples{object: :anna, predicate: :knows, subject: :camille},
                %Types.Triples{object: :camille, predicate: :knows, subject: :anna}
              ]} == QueryEngine.query(graph, [:__var1, :__var2, :__var3])
    end

    test "use one blank and 2 literals", %{graph: graph} do
      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} == QueryEngine.query(graph, [:__var, :knows, :camille])
    end
  end

  describe "Queries using query structs" do
    test "find triples containing :anna", %{graph: graph} do
      query = Query.find(:anna)

      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :lives_with, object: :bob},
                %Types.Triples{subject: :camille, predicate: :knows, object: :anna},
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} == QueryEngine.query(graph, query)
    end

    test "find triples containing :anna and :camille", %{graph: graph} do
      query = Query.find([:anna, :camille])

      assert {:ok,
              [
                %Types.Triples{object: :bob, predicate: :works_with, subject: :camille},
                %Types.Triples{object: :anna, predicate: :knows, subject: :camille},
                %Types.Triples{object: :camille, predicate: :knows, subject: :anna},
                %Types.Triples{object: :bob, predicate: :lives_with, subject: :anna}
              ]} == QueryEngine.query(graph, query)
    end

    test "find variable", %{graph: graph} do
      query = Query.find(:__any_var)

      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :lives_with, object: :bob},
                %Types.Triples{subject: :camille, predicate: :works_with, object: :bob},
                %Types.Triples{subject: :camille, predicate: :knows, object: :anna},
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} == QueryEngine.query(graph, query)
    end

    test "find variables", %{graph: graph} do
      query = Query.find([:__any_var, :__any_other_var])

      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :lives_with, object: :bob},
                %Types.Triples{subject: :camille, predicate: :works_with, object: :bob},
                %Types.Triples{subject: :camille, predicate: :knows, object: :anna},
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} == QueryEngine.query(graph, query)
    end

    @tag :skip
    test "find triples containing :anna where [:anna, :knows, :camille] ", %{graph: graph} do
      query =
        Query.find_where(:anna, %Types.Triples{
          subject: :anna,
          predicate: :knows,
          object: :camille
        })

      assert {:ok,
              [
                %Types.Triples{subject: :anna, predicate: :knows, object: :camille}
              ]} == QueryEngine.query(graph, query)
    end
  end
end
