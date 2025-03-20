defmodule DottEdge do
  @moduledoc """
  This will define types and behaviours for edges
  """

  @type t :: %__MODULE__{
          label: String.t(),
          type: String.t(),
          nodes: Enumerable.t(),
          attributes: Enumerable.t() | nil
        }

  defstruct label: nil,
            nodes: [],
            type: nil,
            attributes: %{}

  @callback new(label :: String.t(), nodes :: Enumerable.t(), attributes :: Enumerable.t()) ::
              struct()

  def new(nil, _nodes, _attributes) do
    raise "Edge label must be present"
  end

  def new(label, nodes, attributes \\ %{}) do
    %DottEdge{label: label, nodes: nodes, attributes: attributes}
  end
end
