defmodule Solutions.Day06 do
  def solve do
    Inputs.Parser.parse("06")
    |> Stream.map(&String.split(&1))
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn row, acc ->
      row
      |> Stream.with_index()
      |> Enum.reduce(acc, &parse_instruction/2)
    end)
    |> Map.values()
    |> Enum.sum_by(fn {_operation, value} -> value end)
  end

  defp parse_instruction({"+", index}, acc), do: Map.put(acc, index, {&+/2, 0})
  defp parse_instruction({"*", index}, acc), do: Map.put(acc, index, {&*/2, 1})

  defp parse_instruction({instruction, index}, acc) do
    value = String.to_integer(instruction)
    {operation, current_value} = Map.get(acc, index)
    Map.put(acc, index, {operation, operation.(current_value, value)})
  end
end
