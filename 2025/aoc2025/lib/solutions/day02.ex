defmodule Solutions.Day02 do
  def solve do
    {part1, part2} =
      Inputs.Parser.parse("02")
      |> Stream.flat_map(fn input -> String.split(input, ",") end)
      |> Stream.map(&process_range/1)
      |> Enum.reduce({0, 0}, fn {range_sum_p1, range_sum_p2}, {total_p1, total_p2} ->
        {total_p1 + range_sum_p1, total_p2 + range_sum_p2}
      end)

    [part1: part1, part2: part2]
  end

  defp process_range(product_id_range) do
    [start_id, end_id] = String.split(product_id_range, "-")
    range = String.to_integer(start_id)..String.to_integer(end_id)

    part1 =
      range
      |> Stream.filter(&Solutions.Day02.Part1.is_id_invalid?/1)
      |> Enum.sum()

    part2 =
      range
      |> Stream.filter(&Solutions.Day02.Part2.is_id_invalid?/1)
      |> Enum.sum()

    {part1, part2}
  end
end

defmodule Solutions.Day02.Part1 do
  def is_id_invalid?(id) do
    id_string = Integer.to_string(id)
    len = String.length(id_string)

    if rem(len, 2) == 0 do
      {left, right} = String.split_at(id_string, div(len, 2))
      String.equivalent?(left, right)
    else
      false
    end
  end
end

defmodule Solutions.Day02.Part2 do
  def is_id_invalid?(id) do
    id_string = Integer.to_string(id)
    len = String.length(id_string)

    Enum.any?(
      1..div(len, 2),
      fn substring_len ->
        # note: sequences must be repeated _at least_ twice
        if len > 1 and rem(len, substring_len) == 0 do
          {substring, _} = String.split_at(id_string, substring_len)
          repeated = String.duplicate(substring, div(len, substring_len))
          String.equivalent?(id_string, repeated)
        else
          false
        end
      end
    )
  end
end
