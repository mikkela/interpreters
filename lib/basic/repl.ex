defmodule Basic.Repl do
  alias Common.Object.{Environment, Object}
  alias Basic.Lexer
  alias Basic.Parser

  @prompt ">> "

  def loop(env \\ Environment.build()) do
    input = IO.gets(@prompt)
    tokens = Lexer.tokenize(input)
    parser = Parser.from_tokens(tokens)
    {parser, input} = Parser.parse_input(parser)

    case length(parser.errors) do
      0 ->
        #{result, env} = Evaluator.eval(program, env)
        #IO.puts(Object.inspect(result))
        loop(env)

      _ ->
        print_parser_errors(parser.errors)
        loop(env)
    end
  end

  defp print_parser_errors(errors) do
    IO.puts("Woops! We ran into some basic business here!")
    IO.puts("Parser Errors:")
    Enum.each(errors, &IO.puts/1)
  end
end
