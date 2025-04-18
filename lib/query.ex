defmodule Query do
  alias Types.Triples

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
    res = Enum.filter(graph.triples, fn triple -> match_pattern?(triple, pattern) end)

    case res do
      [] -> {:no_results, []}
      _ -> {:ok, res}
    end
  end

  defp triple_filter?(triple, pattern) do
  end

  # when a variable is used in a pattern it is converted into a variable type
  # This means that :__var becomes %Types.PatternVariable{var: :__var}
  defp normalize_pattern(pattern) do
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

  defp subject_filter?(%Triples{subject: s}, [s, _, _]), do: true
  defp predicate_filter?(%Triples{predicate: p}, [_, p, _]), do: true
  defp object_filter?(%Triples{object: o}, [_, _, o]), do: true

  defp match_pattern?(%Triples{subject: s, predicate: p, object: o}, [s, p, o]), do: true
  defp match_pattern?(%Triples{subject: s, predicate: p}, [s, p, _]), do: true
  defp match_pattern?(%Triples{subject: s, object: o}, [s, _, o]), do: true
  defp match_pattern?(%Triples{object: o, predicate: p}, [_, p, o]), do: true
  defp match_pattern?(%Triples{subject: s}, [s, _, _]), do: true
  defp match_pattern?(%Triples{predicate: p}, [_, p, _]), do: true
  defp match_pattern?(%Triples{object: o}, [_, _, o]), do: true
  defp match_pattern?(_, _), do: false
end
