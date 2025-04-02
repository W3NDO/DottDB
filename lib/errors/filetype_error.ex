defmodule Errors.FiletypeError do
  @moduledoc """
  Error raised when attempting to load an edge list from a file that has an unsupported filetype.
  """
  defexception message:
                 "Unsupported filetype. Right now, DottDB only supports importing from `.json` and `.csv` files"
end
