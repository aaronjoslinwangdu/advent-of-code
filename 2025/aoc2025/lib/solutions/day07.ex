defmodule Solutions.Day07 do
  def solve do
    {last_row_paths, splits} =
      Inputs.Parser.parse("07")
      |> Enum.reduce({%{}, 0}, fn row, {prev_row_paths, splits} ->
        row
        |> String.graphemes()
        |> Stream.with_index()
        |> Enum.reduce({%{}, splits}, fn {char, col}, {row_paths, row_splits} ->
          calculate_row_paths_and_splits(char, col, row_paths, prev_row_paths, row_splits)
        end)
      end)

    paths =
      last_row_paths
      |> Map.values()
      |> Enum.sum()

    [part1: splits, part2: paths]
  end

  # this should kick off the accumulation of paths, only running once
  defp calculate_row_paths_and_splits(char, col, row_paths, %{}, 0) when char == "S" do
    {Map.put(row_paths, col, 1), 0}
  end

  # accumulates the paths for the columns to the left + right in the previous row
  defp calculate_row_paths_and_splits(char, col, row_paths, prev_row_paths, splits)
       when char == "^" do
    prev_row_val = Map.get(prev_row_paths, col)

    if prev_row_val != nil do
      row_left = Map.get(row_paths, col - 1, 0)
      left_inc = Map.put(row_paths, col - 1, row_left + prev_row_val)
      left_and_right_inc = Map.put(left_inc, col + 1, prev_row_val)

      {left_and_right_inc, splits + 1}
    else
      {row_paths, splits}
    end
  end

  # accumulates the paths for the column directly above in the previous row
  defp calculate_row_paths_and_splits(char, col, row_paths, prev_row_paths, splits)
       when char == "." do
    prev_row_val = Map.get(prev_row_paths, col)

    if prev_row_val != nil do
      cur_row_val = Map.get(row_paths, col, 0)
      {Map.put(row_paths, col, cur_row_val + prev_row_val), splits}
    else
      {row_paths, splits}
    end
  end
end
