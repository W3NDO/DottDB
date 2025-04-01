defmodule DottNode do
  @typedoc """
  This will define types and behaviours for all the node types
  """

  @type t :: %__MODULE__{
          label: String.t(),
          attributes: Enumerable.t() | nil,
          meta: list(Enumerable.t())
        }

  defstruct label: nil,
            attributes: %{},
            meta: %{}

  @spec new(label :: String.t()) :: t()
  def new(label), do: new(label, %{})

  def new(nil, _attributes) do
    raise ArgumentError, message: "Node label must be present"
  end

  @spec new(label :: String.t(), attributes :: Enumerable.t()) :: t()
  def new(label, attributes) do
    %DottNode{label: label, attributes: attributes, meta: %{read: 0, write: 0}}
  end
end
