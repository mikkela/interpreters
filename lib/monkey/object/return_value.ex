defmodule Monkey.Object.ReturnValue do
  alias Common.Object.Object

  @enforce_keys [:value]
  defstruct [:value]

  defimpl Object, for: __MODULE__ do
    def type(_), do: "RETURN_VALUE"

    def inspect(obj), do: Object.inspect(obj.value)
  end
end
