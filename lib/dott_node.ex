defmodule DottNode do
  @typedoc """
  This will define types and behaviours for all the node types
  """
  @derive {Inspect, only: [:label, :attributes, :id]}

  @type t :: %__MODULE__{
          label: String.t() | atom(),
          attributes: Enumerable.t() | nil,
          id: integer() | nil,
          meta: list(Enumerable.t())
        }

  defstruct label: nil,
            attributes: %{},
            id: nil,
            meta: %{}

  @spec new(label :: String.t()) :: t()
  def new(label), do: new(label, %{})

  def new(nil, _attributes) do
    raise ArgumentError, message: "Node label must be present"
  end

  @spec new(label :: String.t() | atom(), attributes :: Enumerable.t()) :: t()
  def new(label, attributes) do
    %DottNode{label: label, attributes: attributes, id: nil, meta: %{read: 0, write: 0}}
  end

  @spec add_idx(node :: t(), idx :: integer()) :: t()
  def add_idx(node, idx) do
    %__MODULE__{node | id: idx}
  end
end
