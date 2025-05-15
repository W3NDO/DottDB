defmodule Types.Triples do
  @doc """
  This will provide the implementation for triples in DottDB

  Later we can make the type also support uris
  """

  @type t :: %__MODULE__{
          subject: String.t() | atom(),
          predicate: String.t() | atom(),
          object: String.t() | atom()
        }

  defstruct subject: nil, predicate: nil, object: nil

  @spec new(
          subject :: String.t() | atom(),
          predicate :: String.t() | atom(),
          object :: String.t() | atom()
        ) :: %__MODULE__{}
  def new(subject, predicate, object) do
    %__MODULE__{
      subject: subject,
      predicate: predicate,
      object: object
    }
  end

  @spec has_value?(triple :: t(), value :: atom()) :: boolean()
  def has_value?(%{subject: s, predicate: p, object: o}, value) do
    cond do
      s == value ->
        true

      p == value ->
        true

      o == value ->
        true

      true ->
        false
    end
  end
end
