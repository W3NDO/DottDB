defmodule DottNode do
  @typedoc """
  This will define types and behaviours for all the node types
  """

  @type t :: %__MODULE__{
          label: String.t(),
          attributes: Enumerable.t() | nil
        }

  defstruct label: nil,
            attributes: %{}

  @callback new(label :: String.t()) :: struct()

  def new(nil, _attributes) do
    raise("Node label must be present")
  end

  def new(label, attributes \\ %{}) do
    %DottNode{label: label, attributes: attributes}
  end
end
