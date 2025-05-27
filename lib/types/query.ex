defmodule Types.Query do
  @doc """
  This will provide the struct required for a complex query.
  """

  @type t :: %__MODULE__{
          find: atom() | list(atom()) | nil,
          where: Types.Triples.t() | list(Types.Triples.t()) | nil,
          where_not: Types.Triples.t() | list(Types.Triples.t()) | nil,
          or: Types.Triples.t() | list(Types.Triples.t()) | nil
        }

  defstruct find: nil, where: nil, where_not: nil, or: nil

  # note that here we use the word 'oder' not order as a variable because it is the german word for or.
  # or is a keyword. so we can't use it as a variable
  # A find will match an atom on any position in an empty where pattern. (all the elements in the pattern are variables)

  @spec find(atom() | list(atom())) :: Types.Query.t()
  def find(find),
    do: %__MODULE__{
      find: normalize_variable(find),
      where: nil,
      where_not: nil,
      or: nil
    }

  @spec find_where(
          Types.Triples.t() | list(Types.Triples.t()) | nil,
          Types.Triples.t() | list(Types.Triples.t()) | nil
        ) :: Types.Query.t()
  def find_where(find, where) do
    %__MODULE__{
      find: normalize_variable(find),
      where: normalize_pattern(where) |> pattern_to_triple,
      where_not: nil,
      or: nil
    }
  end

  @spec find_where_not(
          atom() | list(atom()),
          Types.Triples.t() | list(Types.Triples.t()) | nil
        ) :: Types.Query.t()
  def find_where_not(find, where_not) do
    %__MODULE__{
      find: find,
      where: nil,
      where_not: normalize_pattern(where_not) |> pattern_to_triple,
      or: nil
    }
  end

  @spec where_or(
          Types.Triples.t() | list(Types.Triples.t()) | nil,
          Types.Triples.t() | list(Types.Triples.t()) | nil
        ) :: Types.Query.t()
  def where_or(where_pattern, oder),
    do: %__MODULE__{
      find: nil,
      where: normalize_pattern(where_pattern) |> pattern_to_triple(),
      where_not: nil,
      or: normalize_pattern(oder) |> pattern_to_triple()
    }

  @spec q(
          find :: atom() | list(atom()),
          where :: Types.Triples.t() | list(Types.Triples.t()) | nil,
          where_not :: Types.Triples.t() | list(Types.Triples.t()) | nil,
          oder :: Types.Triples.t() | list(Types.Triples.t()) | nil
        ) :: t()
  def q(find, where, where_not, oder),
    do: %__MODULE__{
      find: normalize_variable(find),
      where: normalize_pattern(where) |> pattern_to_triple(),
      where_not: normalize_pattern(where_not) |> pattern_to_triple(),
      or: normalize_pattern(oder) |> pattern_to_triple()
    }

  @spec normalize_pattern(list(atom())) :: Types.PatternVariable.t()
  def normalize_pattern([s, p, o]) do
    Enum.map([s, p, o], fn part ->
      case is_user_variable?(part) do
        true -> %Types.PatternVariable{var: part}
        false -> part
      end
    end)
  end

  def normalize_pattern(patterns) do
    Enum.map(patterns, fn pattern -> normalize_pattern(pattern) end)
  end

  def normalize_variable(parts) do
    case is_list(parts) do
      true ->
        Enum.map(parts, fn part ->
          case is_user_variable?(part) do
            true -> %Types.PatternVariable{var: part}
            false -> part
          end
        end)

      false ->
        case is_user_variable?(parts) do
          true -> %Types.PatternVariable{var: parts}
          false -> parts
        end
    end
  end

  def is_user_variable?(part) do
    case is_atom(part) and String.starts_with?(Atom.to_string(part), "__") do
      false -> false
      true -> true
    end
  end

  defp pattern_to_triple([s, p, o]) do
    %Types.Triples{
      subject: s,
      predicate: p,
      object: o
    }
  end

  def is_query_struct?(query) do
    case is_map(query) do
      false ->
        false

      true ->
        keys = [:find, :where, :where_not, :or]

        Enum.all?(keys, fn key -> Map.has_key?(query, key) end)
    end
  end
end
