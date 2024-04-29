defmodule Basic.Parser do
  alias Basic.Ast.{
    BeginExpression,
    CallExpression,
    Identifier,
    IntegerLiteral,
    FunctionLiteral,
    IfExpression,
    WhileExpression,
    SetExpression
  }

  alias Basic.Parser
  alias Basic.Token

  @enforce_keys [:curr, :peek, :tokens, :errors]
  defstruct [:curr, :peek, :tokens, :errors]

  def from_tokens(tokens) do
    [curr | [peek | rest]] = tokens
    %Parser{curr: curr, peek: peek, tokens: rest, errors: []}
  end

  def parse_input(p), do: do_parse_input(p)

  defp do_parse_input(%Parser{curr: %Token{type: :eof}} = p) do
    {p, nil}
  end

  defp do_parse_input(%Parser{} = p) do
    cond do
      is_define(p) -> do_parse_function_literal(p)
      true -> do_parse_expression(p)
    end
  end

  defp do_parse_expression(p) do
    with {:ok, p, expression} <- parse_expression(p) do
      {p, expression}
    else
      {:error, p, _} -> {p, nil}
    end
  end

  defp parse_expression(p) do
    case p.curr.type do
      :ident ->
        parse_identifier(p)

      :int ->
        parse_integer_literal(p)

      :lparen ->
        parse_compound(p)

      _ ->
        error = "Could not understand #{p.curr.literal} "
        p = add_error(p, error)
        {:error, p, nil}
    end
  end

  defp parse_identifier(p) do
    identifier = %Identifier{token: p.curr, value: p.curr.literal}
    {:ok, p, identifier}
  end

  defp parse_integer_literal(p) do
    int = Integer.parse(p.curr.literal)

    case int do
      :error ->
        error = "Could not parse #{p.curr.literal} as integer"
        p = add_error(p, error)
        {:error, p, nil}

      {val, _} ->
        expression = %IntegerLiteral{token: p.curr, value: val}
        {:ok, p, expression}
    end
  end

  defp parse_compound(p) do
    p = next_token(p)

    result =
      case p.curr.type do
        :begin ->
          parse_begin(p)

        :if ->
          parse_if(p)

        :set ->
          parse_set(p)

        :while ->
          parse_while(p)

        :plus ->
          parse_call(p)

        :minus ->
          parse_call(p)

        :asterisk ->
          parse_call(p)

        :slash ->
          parse_call(p)

        :eq ->
          parse_call(p)

        :lt ->
          parse_call(p)

        :gt ->
          parse_call(p)

        :print ->
          parse_call(p)

        :ident ->
          parse_call(p)

        _ ->
          error = "Could not understand #{p.curr.literal} "
          p = add_error(p, error)
          {:error, p, nil}
      end

    with {:ok, p, expression} <- result,
         {:ok, p, _} <- expect_peek(p, :rparen) do
      {:ok, p, expression}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_if(p) do
    if_token = p.curr
    p = next_token(p)

    with {:ok, p, condition} <- parse_expression(p),
         p <- next_token(p),
         {:ok, p, consequence} <- parse_expression(p),
         p <- next_token(p),
         {:ok, p, alternative} <- parse_expression(p) do
      {:ok, p,
       %IfExpression{
         token: if_token,
         condition: condition,
         consequence: consequence,
         alternative: alternative
       }}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_while(p) do
    while_token = p.curr
    p = next_token(p)

    with {:ok, p, test} <- parse_expression(p),
         p <- next_token(p),
         {:ok, p, body} <- parse_expression(p) do
      {:ok, p,
       %WhileExpression{
         token: while_token,
         test: test,
         body: body
       }}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_set(p) do
    set_token = p.curr
    p = next_token(p)

    with {:ok, p, name} <- parse_identifier(p),
         p <- next_token(p),
         {:ok, p, value} <- parse_expression(p) do
      {:ok, p,
       %SetExpression{
         token: set_token,
         name: name,
         value: value
       }}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_begin(p) do
    begin_token = p.curr
    p = next_token(p)

    with {:ok, p, first} <- parse_expression(p),
         {:ok, p, rest} <- parse_expression_list(p) do
      {:ok, p,
       %BeginExpression{
         token: begin_token,
         expressions: [first | rest]
       }}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_call(p) do
    call_token = p.curr

    with {:ok, p, arguments} <- parse_expression_list(p) do
      {:ok, p,
       %CallExpression{
         token: call_token,
         function: call_token.literal,
         arguments: arguments
       }}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_expression_list(%Parser{peek: %Token{type: :rparen}} = p) do
    {:ok, p, []}
  end

  defp parse_expression_list(p) do
    p = next_token(p)

    with {:ok, p, expression} <- parse_expression(p),
         {:ok, p, rest} <- parse_expression_list(p) do
      {:ok, p, [expression | rest]}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp is_define(p), do: p.curr.type == :lparen && p.peek.type == :define

  defp do_parse_function_literal(p) do
    p = next_token(p)
    with {:ok, p, expression} <- parse_function_literal(p) do
      {p, expression}
    else
      {:error, p, _} -> {p, nil}
    end
  end

  defp parse_function_literal(p) do
    function_literal_token = p.curr
    p = next_token(p)

    with {:ok, p, name} <- parse_identifier(p),
         {:ok, p, _peek} <- expect_peek(p, :lparen),
         {:ok, p, parameters} <- parse_argument_list(p),
         p <- next_token(p),
         {:ok, p, body} <- parse_expression(p),
         {:ok, p, _peek} <- expect_peek(p, :rparen) do
      {:ok, p,
        %FunctionLiteral{
          token: function_literal_token,
          name: name.value,
          parameters: parameters,
          body: body
        }}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp parse_argument_list(%Parser{peek: %Token{type: :rparen}} = p) do
    p = next_token(p)
    {:ok, p, []}
  end

  defp parse_argument_list(p) do
    p = next_token(p)

    with {:ok, p, argument} <- parse_identifier(p),
         {:ok, p, rest} <- parse_argument_list(p) do
      {:ok, p, [argument | rest]}
    else
      {_, p, _} -> {:error, p, nil}
    end
  end

  defp add_error(p, msg), do: %{p | errors: p.errors ++ [msg]}

  defp next_token(%Parser{tokens: []} = p) do
    %{p | curr: p.peek, peek: nil}
  end

  defp next_token(%Parser{} = p) do
    [next_peek | rest] = p.tokens
    %{p | curr: p.peek, peek: next_peek, tokens: rest}
  end

  defp expect_peek(%Parser{peek: peek} = p, expected_type) do
    if peek.type == expected_type do
      p = next_token(p)
      {:ok, p, peek}
    else
      error = "Expected next token to be :#{expected_type}, got :#{peek.type} instead"
      p = add_error(p, error)
      {:error, p, nil}
    end
  end
end
