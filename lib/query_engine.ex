defmodule QueryEngine do
  alias Types.Query

  @doc """
  This module holds the control logic for processing queries.

  patterns for now are defined as a list of 3 elements. Each element corresponds to the subject, predicate, object format.

  The elements of a pattern could be a variable or a literal.

  a literal is a string like "anna" or an atom like :asn1ct_name

  a variable is an atom that starts with a double underscore, like :__predicate
  we do this because atoms in elixir do not allow question marks unless they are quoted atoms.
  """

  @type literal :: String.t() | atom()
  # figuring out how these should be worked on may involve some form of metaprogramming.
  @type variable :: Types.PatternVariable.t()
  @type pattern ::
          {subject :: literal | variable, predicate :: literal | variable,
           object :: literal | variable}

  @spec query(DottGraph.t(), pattern | Types.Query.t()) ::
          {:ok, list(Types.Triples)} | {:no_results, []}
  def query(graph, pattern) do
    case Query.is_query_struct?(pattern) do
      true ->
        # figure out the find first
        res = match_on_query_struct(graph, pattern)

        case Enum.empty?(res) do
          true -> {:no_results, []}
          false -> {:ok, res}
        end

      false ->
        pattern = Query.normalize_pattern(pattern)

        res =
          Enum.filter(graph.triples, fn triple ->
            match?({:ok, _}, match_pattern?(triple, pattern))
          end)

        case res do
          [] -> {:no_results, []}
          _ -> {:ok, res}
        end
    end
  end

  # when a variable is used in a pattern it is converted into a variable type
  # This means that :__var becomes %Types.PatternVariable{var: :__var}

  def has_variable?([s, p, o]) do
    case [s, p, o] do
      [%Types.PatternVariable{var: _s}, _, _] -> true
      [_, %Types.PatternVariable{var: _s}, _] -> true
      [_, _, %Types.PatternVariable{var: _s}] -> true
      _ -> false
    end
  end

  @spec match_pattern?(%Types.Triples{}, list()) :: {:no_match, []} | {:ok, list()}
  def match_pattern?(
        %Types.Triples{subject: g_subject, predicate: g_predicate, object: g_object},
        [p_subect, p_predictae, p_object]
      ) do
    matches =
      Enum.zip([g_subject, g_predicate, g_object], [p_subect, p_predictae, p_object])
      |> Enum.map(fn {graph_elem, pattern_elem} ->
        cond do
          graph_elem == pattern_elem ->
            [true, [graph_elem, pattern_elem]]

          Types.PatternVariable.is_pattern_variable?(pattern_elem) && is_atom(graph_elem) == true ->
            [true, [graph_elem, pattern_elem.var]]

          true ->
            [false, [graph_elem, pattern_elem]]
        end
      end)

    res = Enum.map(matches, fn entry -> hd(entry) end) |> Enum.all?()

    assignments =
      if res == true do
        Enum.map(matches, fn [_, maps] -> maps end)
      else
        []
      end

    case res do
      true ->
        {:ok, assignments}

      _ ->
        {:no_match, []}
    end
  end

  @spec match_on_query_struct(graph :: DottGraph, query :: Types.Query) ::
          list(Types.Triples) | nil
  def match_on_query_struct(graph, %Types.Query{
        find: find_clause,
        where: nil,
        where_not: nil,
        or: nil
      }) do
    find_match(graph, [], find_clause)
  end

  def match_on_query_struct(graph, %Types.Query{
        find: find_clause,
        where: where_clause,
        where_not: nil,
        or: nil
      }) do
    IO.inspect(3)
    nil
  end

  def match_on_query_struct(graph, %Types.Query{
        find: find_clause,
        where: nil,
        where_not: where_not_clause,
        or: nil
      }) do
    IO.inspect(2)
    nil
  end

  def match_on_query_struct(graph, %Types.Query{
        find: find_clause,
        where: where_clause,
        where_not: where_not_clause,
        or: or_clause
      }) do
    IO.inspect(1)
    nil
  end

  def find_match(_graph, matches, []) do
    matches
  end

  def find_match(graph, matches, [head | other_find_clauses]) do
    new_matches = find_match(graph, matches, head)
    find_match(graph, new_matches, other_find_clauses)
  end

  @spec find_match(
          graph :: DottGraph,
          matches :: list(),
          find_clause :: atom() | Types.PatternVariable.t()
        ) :: list(Types.Triples.t())
  def find_match(graph, matches, find_clause) do
    case Types.PatternVariable.is_pattern_variable?(find_clause) do
      true ->
        IO.inspect("Is tuple", label: "Pattern Var")
        graph.triples

      false ->
        [
          Enum.filter(graph.triples, fn triple ->
            Types.Triples.has_value?(triple, find_clause)
          end)
          | matches
        ]
        |> List.flatten()
        |> Enum.uniq()
    end
  end
end
