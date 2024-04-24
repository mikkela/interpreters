defmodule Basic.LexerTest do
  use ExUnit.Case

  alias Basic.Token

  test "converts a string into a list of tokens" do
    input = "= + * / < > print ( ) define if while set begin basic 1234 -5674 ; -"

    expected = [
      %Token{type: :eq, literal: "="},
      %Token{type: :plus, literal: "+"},
      %Token{type: :asterisk, literal: "*"},
      %Token{type: :slash, literal: "/"},
      %Token{type: :lt, literal: "<"},
      %Token{type: :gt, literal: ">"},
      %Token{type: :print, literal: "print"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :define, literal: "define"},
      %Token{type: :if, literal: "if"},
      %Token{type: :while, literal: "while"},
      %Token{type: :set, literal: "set"},
      %Token{type: :begin, literal: "begin"},
      %Token{type: :ident, literal: "basic"},
      %Token{type: :int, literal: "1234"},
      %Token{type: :int, literal: "-5674"},
      %Token{type: :minus, literal: "-"},
      %Token{type: :eof, literal: ""}
    ]

    tokens = Basic.Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&assert elem(&1, 0) == elem(&1, 1))
  end

  test "converts real basic code into a list of tokens" do
    input = """
    (while (< y 0) (begin (set x (+ x x))))
    (define +1 (x) (+ x 1))
    (define <> (x y) (not (= x y)))
    """

    expected = [
      %Token{type: :lparen, literal: "("},
      %Token{type: :while, literal: "while"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :lt, literal: "<"},
      %Token{type: :ident, literal: "y"},
      %Token{type: :int, literal: "0"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :begin, literal: "begin"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :set, literal: "set"},
      %Token{type: :ident, literal: "x"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :plus, literal: "+"},
      %Token{type: :ident, literal: "x"},
      %Token{type: :ident, literal: "x"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},

      %Token{type: :lparen, literal: "("},
      %Token{type: :define, literal: "define"},
      %Token{type: :ident, literal: "+1"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :ident, literal: "x"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :plus, literal: "+"},
      %Token{type: :ident, literal: "x"},
      %Token{type: :int, literal: "1"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},

      %Token{type: :lparen, literal: "("},
      %Token{type: :define, literal: "define"},
      %Token{type: :ident, literal: "<>"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :ident, literal: "x"},
      %Token{type: :ident, literal: "y"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :ident, literal: "not"},
      %Token{type: :lparen, literal: "("},
      %Token{type: :eq, literal: "="},
      %Token{type: :ident, literal: "x"},
      %Token{type: :ident, literal: "y"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :rparen, literal: ")"},
      %Token{type: :eof, literal: ""}
    ]

    tokens = Basic.Lexer.tokenize(input)

    assert length(tokens) == length(expected)

    Enum.zip(expected, tokens)
    |> Enum.each(&assert elem(&1, 0) == elem(&1, 1))
  end
end
