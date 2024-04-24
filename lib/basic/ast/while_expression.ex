defmodule Basic.Ast.WhileExpression do
  alias Common.Ast.Node

  @enforce_keys [:token, :test, :body]
  defstruct [
    :token,
    # expression
    :test,
    # expression
    :body
  ]

  defimpl Node, for: __MODULE__ do
    def token_literal(statement), do: statement.token.literal

    def node_type(_), do: :statement

    def to_string(expression) do
      test = Node.to_string(expression.test)
      body = Node.to_string(expression.body)
      "(while #{test} #{body})"
    end
  end
end
