defmodule Solutions.Day02 do
  def solve do
    Inputs.Parser.parse("02")
    |> Stream.flat_map(fn input -> String.split(input, ",") end)
    |> Stream.map(fn product_id_range -> String.split(product_id_range, "-") end)
    |> Stream.map(&process_range/1)
    |> Enum.sum()
  end

  defp process_range([start_id, end_id]) do
    Enum.reduce(
      String.to_integer(start_id)..String.to_integer(end_id),
      0,
      &process_id/2
    )
  end

  defp process_id(id, acc) do
    if is_id_invalid?(id) do
      acc + id
    else
      acc
    end
  end

  defp is_id_invalid?(id) do
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
