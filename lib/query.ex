defmodule Query do
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

  def query(graph, pattern) do
    pattern = normalize_pattern(pattern)

    res =
      Enum.filter(graph.triples, fn triple ->
        match?({:ok, _}, match_pattern?(triple, pattern))
      end)

    case res do
      [] -> {:no_results, []}
      _ -> {:ok, res}
    end
  end

  # when a variable is used in a pattern it is converted into a variable type
  # This means that :__var becomes %Types.PatternVariable{var: :__var}
  def normalize_pattern(pattern) do
    Enum.map(pattern, fn part ->
      case is_user_variable?(part) do
        true -> %Types.PatternVariable{var: part}
        false -> part
      end
    end)
  end

  defp is_user_variable?(part) do
    case is_atom(part) and String.starts_with?(Atom.to_string(part), "__") do
      false -> false
      true -> true
    end
  end

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
end
