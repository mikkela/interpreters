defmodule Basic.Token do
  @enforce_keys [:type, :literal]
  defstruct [:type, :literal]

  @keywords %{
    "define" => :define,
    "if" => :if,
    "while" => :while,
    "set" => :set,
    "begin" => :begin,
    "print" => :print
  }

  @types %{
    illegal: "ILLEGAL",
    eof: "EOF",
    # identifiers and literals
    # add, foobar, x, y, ...
    ident: "IDENT",
    # 123
    int: "INT",
    # operators
    plus: "+",
    minus: "-",
    asterisk: "*",
    slash: "/",
    eq: "=",
    lt: "<",
    gt: ">",
    # delimiters
    semicolon: ",",
    lparen: "(",
    rparen: ")",
    # keywords
    define: "DEFINE",
    if: "IF",
    while: "WHILE",
    set: "SET",
    begin: "BEGIN",
    print: "PRINT",
  }

  def new(type: type, literal: literal) when is_atom(type) and is_binary(literal) do
    if Map.has_key?(@types, type) do
      %__MODULE__{type: type, literal: literal}
    else
      raise "Token with type #{inspect(type)} is not defined"
    end
  end

  def lookup_ident(ident) do
    Map.get(@keywords, ident, :ident)
  end
end
