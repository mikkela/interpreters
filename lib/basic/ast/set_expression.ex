defmodule Basic.Ast.SetExpression do
  alias Common.Ast.Node

  @enforce_keys [:token, :name, :value]
  defstruct [
    :token,
    # identifier
    :name,
    # expression
    :value
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(expression) do
      name = Node.to_string(expression.name)
      value = Node.to_string(expression.value)
      "(set #{name} #{value})"
    end
  end
end
