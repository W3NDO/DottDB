defmodule DottEdge do
  @moduledoc """
  This will define types and behaviours for edges
  """

  @type t :: %__MODULE__{
          label: String.t(),
          type: Atom.t(),
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

  def new(nil, _src, _dest, _nodes, _attributes) do
    raise ArgumentError, message: "Edge label must be present"
  end

  def new(label, src_node_label, dest_node_label),
    do: new(label, src_node_label, dest_node_label, %{}, :undirected)

  def new(label, src_node_label, dest_node_label, attributes),
    do: new(label, src_node_label, dest_node_label, attributes, :undirected)

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
