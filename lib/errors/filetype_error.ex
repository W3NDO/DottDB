defmodule Errors.FiletypeError do
  @moduledoc """
  This will define custom errors used in the Dott project
  """
  defexception message:
                 "Unsupported filetype. Right now, DottDB only supports importing from `.json` and `.csv` files"
end
