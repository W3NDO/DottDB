defmodule Types.Query do
  @doc """
  This will provide the struct required for a complex query.
  """

  @type t :: %__MODULE__{
          find: atom() | list(atom()),
          where: Types.Triples.t() | list(Types.Triples.t()) | nil,
          where_not: Types.Triples.t() | list(Types.Triples.t()) | nil,
          or: Types.Triples.t() | list(Types.Triples.t()) | nil
        }

  defstruct find: nil, where: nil, where_not: nil, or: nil
end
