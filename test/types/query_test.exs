defmodule Types.QueryTest do
  use ExUnit.Case
  alias Types.Query

  describe "returns a query struct" do
    test ">> find" do
      assert %Types.Query{
               find: :anna,
               where: nil,
               where_not: nil,
               or: nil
             } == Query.find(:anna)
    end

    test ">> find where" do
      assert %Types.Query{
               find: :anna,
               where: %Types.Triples{
                 subject: :anna,
                 predicate: :knows,
                 object: %Types.PatternVariable{var: :__var}
               },
               where_not: nil,
               or: nil
             } == Query.find_where(:anna, [:anna, :knows, :__var])
    end

    test ">> find_where_not" do
      assert %Types.Query{
               find: [:anna, :knows, :camille],
               where: nil,
               where_not: %Types.Triples{
                 subject: :anna,
                 predicate: :knows,
                 object: %Types.PatternVariable{var: :__var}
               },
               or: nil
             } = Query.find_where_not([:anna, :knows, :camille], [:anna, :knows, :__var])
    end

    test ">> where_or" do
      assert %Types.Query{
               find: nil,
               where: %Types.Triples{
                 subject: :anna,
                 predicate: :knows,
                 object: %Types.PatternVariable{var: :__var1}
               },
               where_not: nil,
               or: %Types.Triples{
                 subject: %Types.PatternVariable{var: :__var1},
                 predicate: :knows,
                 object: :camille
               }
             } = Query.where_or([:anna, :knows, :__var1], [:__var1, :knows, :camille])
    end

    test ">> q" do
      assert %Types.Query{
               find: :anna,
               where: %Types.Triples{
                 subject: :anna,
                 predicate: :knows,
                 object: %Types.PatternVariable{var: :__var}
               },
               where_not: %Types.Triples{
                 subject: %Types.PatternVariable{var: :__var},
                 predicate: :knows,
                 object: :anna
               },
               or: %Types.Triples{
                 subject: :anna,
                 predicate: :lives_with,
                 object: %Types.PatternVariable{var: :__var2}
               }
             } =
               Query.q(:anna, [:anna, :knows, :__var], [:__var, :knows, :anna], [
                 :anna,
                 :lives_with,
                 :__var2
               ])
    end
  end
end
