defmodule Basic.Ast.IfExpression do
  alias Common.Ast.Node

  @enforce_keys [:token, :condition, :consequence, :alternative]
  defstruct [
    :token,
    # expression
    :condition,
    # expression
    :consequence,
    # expressiont
    :alternative
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      condition = Node.to_string(expression.condition)
      consequence = Node.to_string(expression.consequence)
      alternative = Node.to_string(expression.alternative)
      "(if #{condition} #{consequence} #{alternative})"
    end
  end
end
