defmodule Mix.Tasks.Basic do
  use Mix.Task

  def run(_) do
    user = "whoami" |> System.cmd([]) |> elem(0) |> String.trim_trailing()

    IO.puts("Hello #{user}! This is the Basic programming language")
    IO.puts("Feel free to type in commands")
  end
end
