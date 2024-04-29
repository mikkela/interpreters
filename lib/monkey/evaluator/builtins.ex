defmodule Monkey.Evaluator.Builtins do
  alias Common.Object.{
    Error,
    Null,
    Object
  }

  alias Monkey.Object.{
    Builtin
  }

  def get("len"), do: %Builtin{fn: &len/1}
  def get("puts"), do: %Builtin{fn: &puts/1}
  def get(_), do: nil

  def len([arg] = args) when length(args) == 1 do
    case arg do
      %Monkey.Object.String{} ->
        result = String.length(arg.value)
        %Monkey.Object.Integer{value: result}

      %Monkey.Object.Array{} ->
        result = length(arg.elements)
        %Monkey.Object.Integer{value: result}

      _ ->
        error("argument to `len` not supported, got #{Object.type(arg)}")
    end
  end

  def len(args), do: error("wrong number of arguments. got=#{length(args)}, want=1")

  def puts(args) do
    Enum.each(args, fn arg ->
      arg
      |> Object.inspect()
      |> IO.puts()
    end)

    %Null{}
  end

  defp error(message), do: %Error{message: message}
end
