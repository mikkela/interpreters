defmodule Monkey.Ast.InfixExpression do
  alias Common.Ast.Node

  @enforce_keys [:token, :left, :operator, :right]
  defstruct [
    # the operator token
    :token,
    # expression
    :left,
    :operator,
    # expression
    :right
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      left = Node.to_string(expression.left)
      operator = expression.operator
      right = Node.to_string(expression.right)
      "(#{left} #{operator} #{right})"
    end
  end
end
