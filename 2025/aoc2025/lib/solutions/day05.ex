defmodule Solutions.Day05 do
  @filename "05"

  def solve do
    intervals =
      Inputs.Parser.parse(@filename)
      |> Stream.filter(fn range_str -> String.contains?(range_str, "-") end)
      |> Stream.map(fn range_str ->
        [left, right] = String.split(range_str, "-")
        {String.to_integer(left), String.to_integer(right)}
      end)
      |> Enum.sort()
      |> Enum.reduce([], &merge_intervals/2)
      |> Enum.reduce([], fn {left, right}, acc ->
        case acc do
          [] -> [left | [right]]
          rest -> [left | [right | rest]]
        end
      end)
      |> List.to_tuple()

    fresh_ingredients =
      Inputs.Parser.parse(@filename)
      |> Stream.filter(fn range_str ->
        not String.contains?(range_str, "-") and String.length(range_str) > 0
      end)
      |> Stream.map(&String.to_integer/1)
      |> Stream.map(fn target ->
        binary_search(0, tuple_size(intervals) - 1, intervals, target)
      end)
      |> Enum.reduce(0, fn insert_idx, cur_fresh_ingredients ->
        # since intervals will be of the form [start1, end1, start2, end2], inserting at an 
        # even index means in between a end-start range, which is not fresh
        if Integer.mod(insert_idx, 2) == 1 do
          cur_fresh_ingredients + 1
        else
          cur_fresh_ingredients
        end
      end)

    [part1: fresh_ingredients, part2: :ok]
  end

  defp merge_intervals({left, right}, []), do: [{left, right}]

  defp merge_intervals({left, right}, [{prev_left, prev_right} | rest]) do
    if left <= prev_right do
      [{prev_left, max(prev_right, right)} | rest]
    else
      [{left, right} | [{prev_left, prev_right} | rest]]
    end
  end

  defp binary_search(left, right, _intervals, _target) when right < left, do: left

  defp binary_search(left, right, intervals, target) do
    mid = left + div(right - left, 2)

    if elem(intervals, mid) < target do
      binary_search(mid + 1, right, intervals, target)
    else
      binary_search(left, mid - 1, intervals, target)
    end
  end
end
