defmodule Solutions.Day09 do
  def solve do
    points =
      Inputs.Parser.parse("09")
      |> Stream.map(fn str ->
        str
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
      end)
      |> Stream.map(&List.to_tuple/1)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {point, index}, acc ->
        Map.put(acc, index, point)
      end)

    n = map_size(points)

    max_area =
      0..(n - 2)
      |> Enum.reduce(0, fn i, max_area_acc ->
        (i + 1)..(n - 1)
        |> Enum.reduce(max_area_acc, fn j, cur_max_area ->
          p1 = Map.get(points, i)
          p2 = Map.get(points, j)
          max(cur_max_area, area(p1, p2))
        end)
      end)

    [part1: max_area, part2: :wip]
  end

  def area({x1, y1}, {x2, y2}) do
    height = max(x1, x2) - min(x1, x2) + 1
    width = max(y1, y2) - min(y1, y2) + 1
    height * width
  end
end
