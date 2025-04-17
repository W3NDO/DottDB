defmodule DottEdge do
  @moduledoc """
  This will define types and behaviours for edges
  """

  @type t :: %__MODULE__{
          label: String.t(),
          type: atom(),
          src_node_label: String.t(),
          dest_node_label: String.t(),
          attributes: Enumerable.t() | nil,
          meta: Enumerable.t()
        }

  defstruct label: nil,
            src_node_label: nil,
            dest_node_label: nil,
            type: nil,
            attributes: %{},
            meta: %{}

  @callback new(
              label :: String.t(),
              src_node_label :: String.t(),
              dest_node_label :: String.t(),
              type :: String.t(),
              attributes :: Enumerable.t()
            ) ::
              struct()

  @spec new(String.t(), String.t(), String.t()) :: t()
  def new(label, src_node_label, dest_node_label),
    do: new(label, src_node_label, dest_node_label, %{}, :undirected)

  @spec new(String.t(), String.t(), String.t(), Enumerable.t()) :: t()
  def new(label, src_node_label, dest_node_label, attributes),
    do: new(label, src_node_label, dest_node_label, attributes, :undirected)

  @spec new(String.t(), String.t(), String.t(), Enumerable.t(), atom()) :: t()
  def new(nil, _src, _dest, _attributes, _type) do
    raise ArgumentError, message: "Edge label must be present"
  end

  def new(label, src_node_label, dest_node_label, attributes, type) do
    %DottEdge{
      label: label,
      src_node_label: src_node_label,
      dest_node_label: dest_node_label,
      type: type,
      attributes: attributes,
      meta: %{read: 0, write: 0}
    }
  end
end
