defmodule Basic.Ast.FunctionLiteral do
  alias Common.Ast.Node

  @enforce_keys [:token, :name, :parameters, :body]
  defstruct [:token, :name, :parameters, :body ]

  defimpl Node, for: __MODULE__ do
    def token_literal(expression), do: expression.token.literal

    def node_type(_), do: :literal

    def to_string(expression) do
      literal = Node.token_literal(expression)
      body = Node.to_string(expression.body)

      params =
        if length(expression.arguments) > 0 do
          expression.parameters
          |> Enum.map(&Node.to_string/1)
          |> Enum.join(", ")
        else
          ""
        end

      "(define #{literal} (#{params}) #{body})"
    end
  end
end
