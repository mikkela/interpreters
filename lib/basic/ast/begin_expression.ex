defmodule Basic.Ast.BeginExpression do
  alias Common.Ast.Node

  @enforce_keys [:token, :expressions]
  defstruct [:token, :expressions]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :expression

    def to_string(expression) do
      expressions = expression.expressions |> Enum.map(&Node.to_string/1) |> Enum.join()
      "(begin #{expressions})"
    end
  end
end
