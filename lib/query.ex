defmodule Query do
  alias Types.Triples

  @doc """
  This module holds the control logic for processing queries.
  """

  @type literal :: String.t() | atom()
  # @type variable :: String.t() # fighuring out how these should be worked on may involve some form of metaprogramming.
  @type pattern ::
          {subject :: literal, predicate :: literal, object :: literal}

  def query(graph, pattern) do
    res = Enum.filter(graph.triples, fn triple -> match_pattern?(triple, pattern) end)

    case res do
      [] -> {:no_results, []}
      _ -> {:ok, res}
    end
  end

  defp triple_filter?(triple, pattern) do
  end

  defp match_pattern?(%Triples{subject: s, predicate: p, object: o}, [s, p, o]), do: true
  defp match_pattern?(%Triples{subject: s, predicate: p}, [s, p, _]), do: true
  defp match_pattern?(%Triples{subject: s, object: o}, [s, _, o]), do: true
  defp match_pattern?(%Triples{object: o, predicate: p}, [_, p, o]), do: true
  defp match_pattern?(%Triples{subject: s}, [s, _, _]), do: true
  defp match_pattern?(%Triples{predicate: p}, [_, p, _]), do: true
  defp match_pattern?(%Triples{object: o}, [_, _, o]), do: true
  defp match_pattern?(_, _), do: false
end
