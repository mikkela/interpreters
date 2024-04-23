defmodule Basic.Lexer do
  alias Basic.Token

  def tokenize(input) do
    chars = String.split(input, "", trim: true)
    tokenize(chars, [])
  end

  defp tokenize(_chars = [], tokens) do
    Enum.reverse([Token.new(type: :eof, literal: "") | tokens])
  end

  defp tokenize(chars = [ch | rest], tokens) do
    cond do
      is_whitespace(ch) -> tokenize(rest, tokens)
      is_scope_delimiter(ch) -> read_scope_delimiter(chars, tokens)
      is_start_of_number(chars) -> read_number(chars, tokens)
      is_operator(ch) -> read_operator(chars, tokens)
      is_letter(ch) -> read_identifier(chars, tokens)
      true -> Token.new(type: :illegal, literal: "")
    end
  end

  defp read_scope_delimiter(_chars = [ch | rest], tokens) do
    token =
      case ch do
        "(" -> Token.new(type: :lparen, literal: ch)
        ")" -> Token.new(type: :rparen, literal: ch)
        _ -> Token.new(type: :illegal, literal: "")
      end

    tokenize(rest, [token | tokens])
  end
  defp read_identifier(chars, tokens) do
    {identifier, rest} = Enum.split_while(chars, &is_letter/1)
    identifier = Enum.join(identifier)
    token = Token.new(type: Token.lookup_ident(identifier), literal: identifier)

    tokenize(rest, [token | tokens])
  end

  defp read_number(chars, tokens) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)
    number = Enum.join(number)
    token = Token.new(type: :int, literal: number)

    tokenize(rest, [token | tokens])
  end

  defp read_operator(_chars = [ch | rest], tokens) do
    token =
      case ch do
        "=" -> Token.new(type: :eq, literal: ch)
        "+" -> Token.new(type: :plus, literal: ch)
        "-" -> Token.new(type: :minus, literal: ch)
        "*" -> Token.new(type: :asterisk, literal: ch)
        "/" -> Token.new(type: :slash, literal: ch)
        "<" -> Token.new(type: :lt, literal: ch)
        ">" -> Token.new(type: :gt, literal: ch)
        _ -> Token.new(type: :illegal, literal: "")
      end

    tokenize(rest, [token | tokens])
  end

  defp is_letter(ch) do
    !(is_scope_delimiter(ch) || ch == ";")
  end

  defp is_digit(ch) do
    "0" <= ch && ch <= "9"
  end

  defp is_whitespace(ch) do
    ch == " " || ch == "\n" || ch == "\t"
  end

  defp is_scope_delimiter(ch) do
    ch == "(" || ch == ")"
  end

  defp is_start_of_number(chars) do
    is_digit(Enum.at(chars, 0)) || (Enum.at(chars, 0) == '-' && is_digit(Enum.at(chars, 1)))
  end
  defp is_operator_character(ch) do
    (ch == "=" || ch == "+" || ch == "-" || ch == "*" || ch == "/" || ch == "<" || ch == ">")
  end

  defp is_operator(chars) do
    is_operator_character(Enum.at(chars, 0)) &&
                                         (is_whitespace(Enum.at(chars, 1)) || is_scope_delimiter(Enum.at(chars, 1)))
  end
end
