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
      is_comment(ch) -> skip_comment(rest, tokens)
      is_parenthesis(ch) -> read_parenthesis(chars, tokens)
      is_special_character(chars) -> read_special_character(chars, tokens)
      is_negative_number(chars) -> read_negative_number(chars, tokens)
      is_digit(ch) -> read_positive_number(chars, tokens)
      is_identifier(ch) -> read_identifier(chars, tokens)
      true -> [Token.new(type: :illegal, literal: "") | tokens]
    end
  end

  defp read_identifier(chars, tokens) do
    {identifier, rest} = Enum.split_while(chars, &is_identifier/1)
    identifier = Enum.join(identifier)
    token = Token.new(type: Token.lookup_ident(identifier), literal: identifier)

    tokenize(rest, [token | tokens])
  end

  defp read_positive_number(chars, tokens) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)
    number = Enum.join(number)
    token = Token.new(type: :int, literal: number)

    tokenize(rest, [token | tokens])
  end

  defp read_negative_number([_sign | chars], tokens) do
    {number, rest} = Enum.split_while(chars, &is_digit/1)
    number = Enum.join(number)
    token = Token.new(type: :int, literal: "-#{number}")

    tokenize(rest, [token | tokens])
  end

  defp read_special_character(_chars = [ch | rest], tokens) do
    token =
      case ch do
        "=" -> Token.new(type: :eq, literal: ch)
        "+" -> Token.new(type: :plus, literal: ch)
        "-" -> Token.new(type: :minus, literal: ch)
        "*" -> Token.new(type: :asterisk, literal: ch)
        "/" -> Token.new(type: :slash, literal: ch)
        "<" -> Token.new(type: :lt, literal: ch)
        ">" -> Token.new(type: :gt, literal: ch)
      end

    tokenize(rest, [token | tokens])
  end

  defp skip_comment(chars, tokens) do
    {_comment, rest} = Enum.split_while(chars, &is_newline/1)

    tokenize(rest, tokens)
  end

  defp read_parenthesis(_chars = [ch | rest], tokens) do
    token =
      case ch do
        "(" -> Token.new(type: :lparen, literal: ch)
        ")" -> Token.new(type: :rparen, literal: ch)
      end

    tokenize(rest, [token | tokens])
  end

  defp is_identifier(ch) do
    !(is_parenthesis(ch) || is_comment(ch) || is_whitespace(ch))
  end

  defp is_digit(ch) do
    "0" <= ch && ch <= "9"
  end

  defp is_whitespace(ch) do
    ch == " " || ch == "\t" || is_newline(ch)
  end

  defp is_newline(ch) do
    ch == "\n"
  end

  defp is_negative_number(chars) do
    length(chars) > 1 && Enum.at(chars, 0) == "-" && is_digit(Enum.at(chars, 1))
  end

  defp is_comment(ch), do: ch == ";"

  defp is_parenthesis(ch), do: ch == "(" || ch == ")"

  defp is_special_char(ch) do
    case ch do
      "=" -> true
      "+" -> true
      "-" -> true
      "*" -> true
      "/" -> true
      "<" -> true
      ">" -> true
      _ -> false
    end
  end
  defp is_special_character(chars = [ch | rest]) do
    is_special_char(ch) && (
      length(rest) == 0 ||
      is_whitespace(Enum.at(chars, 1)) ||
      is_comment(Enum.at(chars, 1)) ||
      is_parenthesis(Enum.at(chars, 1)))
  end
end
