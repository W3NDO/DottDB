defmodule DottEdge do
  @moduledoc """
  This will define types and behaviours for edges
  """

  # @derive {Inspect, only: [:label, :type, :src_node_label, :dest_node_label, :attributes, :id]}

  @type t :: %__MODULE__{
          label: String.t(),
          type: atom(),
          src_node_label: String.t(),
          dest_node_label: String.t(),
          src_node_id: integer() | nil,
          dest_node_label: integer() | nil,
          attributes: Enumerable.t() | nil,
          meta: Enumerable.t(),
          id: integer() | nil
        }

  defstruct label: nil,
            src_node_label: nil,
            dest_node_label: nil,
            src_node_id: nil,
            dest_node_id: nil,
            type: nil,
            attributes: %{},
            meta: %{},
            id: nil

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

  @spec new(String.t(), String.t(), String.t(), Enumerable.t(), atom()) :: t()
  def new(_label, nil, _dest, _attributes, _type) do
    raise ArgumentError, message: "Source Node label must be present"
  end

  @spec new(String.t(), String.t(), String.t(), Enumerable.t(), atom()) :: t()
  def new(_label, _src, nil, _attributes, _type) do
    raise ArgumentError, message: "Destination Node label must be present"
  end

  def new(label, src_node_label, dest_node_label, attributes, type) do
    %DottEdge{
      label: label,
      src_node_label: src_node_label,
      dest_node_label: dest_node_label,
      src_node_id: nil,
      dest_node_id: nil,
      type: type,
      attributes: attributes,
      meta: %{read: 0, write: 0},
      id: nil
    }
  end

  @spec add_idx(edge :: t(), idx :: integer()) :: t()
  def add_idx(edge, idx) do
    %__MODULE__{edge | id: idx}
  end
end
