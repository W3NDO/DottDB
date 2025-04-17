defmodule Types.TriplesTest do
  use ExUnit.Case
  alias Types.Triples

  describe "Building new triples" do
    test "triple with strings in spo" do
      assert %Triples{subject: "Alice", predicate: "Knows", object: "Bob"} =
               Triples.new("Alice", "Knows", "Bob")
    end

    test "triple with atoms in spo" do
      assert %Triples{subject: :alice, predicate: :knows, object: :bob} =
               Triples.new(:alice, :knows, :bob)
    end
  end
end
