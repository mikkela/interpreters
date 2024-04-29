defmodule Common.Object.Error do
  alias Common.Object.Object

  @enforce_keys [:message]
  defstruct [:message]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "ERROR_OBJ"

    def inspect(obj), do: "ERROR: #{obj.message}"
  end
end
