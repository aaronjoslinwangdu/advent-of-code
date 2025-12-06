defmodule Solutions.Day06 do
  @filename "06"

  def solve do
    [
      part1: Solutions.Day06.Part1.solve(@filename),
      part2: Solutions.Day06.Part2.solve(@filename)
    ]
  end
end

defmodule Solutions.Day06.Part1 do
  def solve(filename) do
    Inputs.Parser.parse(filename)
    |> Stream.map(&String.split(&1))
    |> Enum.reverse()
    |> Enum.reduce(%{}, fn row, acc ->
      row
      |> Stream.with_index()
      |> Enum.reduce(acc, &parse_instruction/2)
    end)
    |> Enum.sum_by(fn {_idx, {_op_fun, val}} -> val end)
  end

  defp parse_instruction({"+", idx}, acc), do: Map.put(acc, idx, {&+/2, 0})
  defp parse_instruction({"*", idx}, acc), do: Map.put(acc, idx, {&*/2, 1})

  defp parse_instruction({ins, idx}, acc) do
    val = String.to_integer(ins)
    {op_fun, cur_val} = Map.get(acc, idx)
    Map.put(acc, idx, {op_fun, op_fun.(cur_val, val)})
  end
end

defmodule Solutions.Day06.Part2 do
  def solve(filename) do
    {nums_by_col_idx, ops} =
      "lib/inputs/#{filename}.txt"
      |> File.stream!()
      |> Enum.reduce({%{}, []}, fn row, acc ->
        row
        |> String.graphemes()
        |> Stream.with_index()
        |> Enum.reduce(acc, &parse_instruction/2)
      end)

    ops
    |> Enum.reduce(0, fn {op_fun, start_val, range_start, range_end}, acc ->
      range_start..range_end
      |> Enum.reduce(start_val, fn index, group_acc ->
        op_fun.(group_acc, Map.get(nums_by_col_idx, index))
      end)
      |> Kernel.+(acc)
    end)
  end

  defp parse_instruction({ins, idx}, {nums_by_col_idx, ops})
       when ins == "+" or ins == "*" do
    case ins do
      "+" -> {nums_by_col_idx, [{&+/2, 0, idx, -1} | ops]}
      "*" -> {nums_by_col_idx, [{&*/2, 1, idx, -1} | ops]}
    end
  end

  defp parse_instruction({ins, idx}, {nums_by_col_idx, ops}) do
    case Integer.parse(ins) do
      :error ->
        case ops do
          [] ->
            {nums_by_col_idx, []}

          _ ->
            [{ins, start_val, range_start, _} | rest] = ops
            {nums_by_col_idx, [{ins, start_val, range_start, idx - 1} | rest]}
        end

      {digit, ""} ->
        idx_val = Map.get(nums_by_col_idx, idx, 0)
        {Map.put(nums_by_col_idx, idx, idx_val * 10 + digit), ops}
    end
  end
end
