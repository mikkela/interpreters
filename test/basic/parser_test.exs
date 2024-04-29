defmodule Basic.ParserTest do
  use ExUnit.Case

  alias Common.Ast.Node
  alias Basic.Lexer
  alias Basic.Token
  alias Basic.Parser
  alias Basic.Ast.IntegerLiteral
  alias Basic.Ast.Identifier
  alias Basic.Ast.BeginExpression
  alias Basic.Ast.IfExpression
  alias Basic.Ast.FunctionLiteral
  alias Basic.Ast.SetExpression
  alias Basic.Ast.WhileExpression
  alias Basic.Ast.CallExpression

  def parse_input(input) do
    tokens = Lexer.tokenize(input)
    parser = Parser.from_tokens(tokens)
    {parser, result} = Parser.parse_input(parser)

    if length(parser.errors) > 0, do: IO.inspect(parser.errors)
    assert length(parser.errors) == 0

    {parser, result}
  end

  def parse_result_is_expression(input) do
    {_, result} = parse_input(input)
    assert result != nil

    result
  end

  def parse_result_is_function_literal(input) do
    {_, result} = parse_input(input)
    assert result != nil
    assert %FunctionLiteral{} = result

    result
  end

  def test_integer_literal(expression, value) do
    assert %IntegerLiteral{} = expression
    assert expression.value == value
    assert Node.token_literal(expression) == Integer.to_string(value)
  end

  def test_identifier(expression, value) do
    assert %Identifier{} = expression
    assert expression.value == value
    assert Node.token_literal(expression) == value
  end

  def test_if(expression) do
    assert %IfExpression{} = expression
    assert expression.condition != nil
    assert expression.consequence != nil
    assert expression.alternative != nil
    assert Node.token_literal(expression) == "if"
  end

  def test_while(expression) do
    assert %WhileExpression{} = expression
    assert expression.test != nil
    assert expression.body != nil
    assert Node.token_literal(expression) == "while"
  end

  def test_set(expression) do
    assert %SetExpression{} = expression
    assert expression.name != nil
    assert expression.value != nil
    assert Node.token_literal(expression) == "set"
  end

  def test_begin(expression) do
    assert %BeginExpression{} = expression
    assert length(expression.expressions) > 0
    assert Node.token_literal(expression) == "begin"
  end

  def test_call(expression, name) do
    assert %CallExpression{} = expression
    assert length(expression.arguments) >= 0
    assert expression.function == name
    assert Node.token_literal(expression) == name
  end

  test "parse identifier expression" do
    input = "foobar"
    expression = parse_result_is_expression(input)

    identifier = expression
    test_identifier(identifier, "foobar")
  end

  test "parse integer literal expression" do
    input = "5"
    expression = parse_result_is_expression(input)

    literal = expression
    test_integer_literal(literal, 5)
  end

  test "parse if expression" do
    input = "(if x y z)"
    expression = parse_result_is_expression(input)

    if = expression
    test_if(if)
    test_identifier(if.condition, "x")
    test_identifier(if.consequence, "y")
    test_identifier(if.alternative, "z")
  end

  test "parse while expression" do
    input = "(while y z)"
    expression = parse_result_is_expression(input)

    while = expression
    test_while(while)
    test_identifier(while.test, "y")
    test_identifier(while.body, "z")
  end

  test "parse set expression" do
    input = "(set name 657)"
    expression = parse_result_is_expression(input)

    set = expression
    test_set(set)
    test_identifier(set.name, "name")
    test_integer_literal(set.value, 657)
  end

  test "parse begin expression" do
    input = "(begin qer qef (if x y z))"
    expression = parse_result_is_expression(input)

    begin = expression
    test_begin(begin)
    assert length(begin.expressions) == 3
    test_identifier(Enum.at(begin.expressions, 0), "qer")
    test_identifier(Enum.at(begin.expressions, 1), "qef")
    if = Enum.at(begin.expressions, 2)
    test_if(if)
    test_identifier(if.condition, "x")
    test_identifier(if.consequence, "y")
    test_identifier(if.alternative, "z")
  end

  test "parse + expression" do
    input = "(+ 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "+")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse - expression" do
    input = "(- 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "-")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse * expression" do
    input = "(* 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "*")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse / expression" do
    input = "(/ 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "/")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse = expression" do
    input = "(= 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "=")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse < expression" do
    input = "(< 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "<")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse > expression" do
    input = "(> 3 4)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, ">")
    assert length(plus.arguments) == 2
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
  end

  test "parse print expression" do
    input = "(print 44)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "print")
    assert length(plus.arguments) == 1
    test_integer_literal(Enum.at(plus.arguments, 0), 44)
  end

  test "parse qed expression" do
    input = "(qed 3 4 6)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "qed")
    assert length(plus.arguments) == 3
    test_integer_literal(Enum.at(plus.arguments, 0), 3)
    test_integer_literal(Enum.at(plus.arguments, 1), 4)
    test_integer_literal(Enum.at(plus.arguments, 2), 6)
  end

  test "parse <> expression" do
    input = "(<>)"
    expression = parse_result_is_expression(input)

    plus = expression
    test_call(plus, "<>")
    assert length(plus.arguments) == 0
  end

  test "parse function definition" do
    input = "(define +1 (x) (+ x 1))"
    function = parse_result_is_function_literal(input)

    assert function.name == "+1"
    assert length(function.parameters) == 1
    test_identifier(Enum.at(function.parameters, 0), "x")
    test_call(function.body, "+")
  end
end
