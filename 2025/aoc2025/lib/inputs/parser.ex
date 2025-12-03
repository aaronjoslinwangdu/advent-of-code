defmodule Inputs.Parser do
  def parse(filename) do
    "lib/inputs/#{filename}.txt"
    |> File.stream!()
    |> Stream.map(&String.trim/1)
  end
end
