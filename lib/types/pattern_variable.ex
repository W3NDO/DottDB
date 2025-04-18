defmodule Types.PatternVariable do
  @type t :: %__MODULE__{
          var: atom()
        }

  defstruct [:var]
end
