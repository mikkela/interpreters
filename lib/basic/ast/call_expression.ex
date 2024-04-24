defmodule Basic.Ast.CallExpression do
  alias Common.Ast.Node

  @enforce_keys [:token, :function]
  defstruct [
    :token,
    # optr (function or value-op)
    :function,
    # expression[]
    :arguments
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      function = Node.to_string(expression.function)

      arguments =
        if length(expression.arguments) > 0 do
          expression.arguments
          |> Enum.map(&Node.to_string/1)
          |> Enum.join(", ")
        else
          ""
        end
      "(#{function} #{arguments})"
    end
  end
end
