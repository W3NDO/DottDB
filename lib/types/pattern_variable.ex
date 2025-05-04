defmodule Types.PatternVariable do
  @type t :: %__MODULE__{
          var: atom()
        }

  defstruct [:var]

  def is_pattern_variable?(%Types.PatternVariable{var: _}), do: true
  def is_pattern_variable?(_), do: false
end
