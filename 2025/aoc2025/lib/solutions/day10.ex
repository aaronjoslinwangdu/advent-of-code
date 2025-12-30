defmodule Solutions.Day10 do
  def solve do
    rows =
      Inputs.Parser.parse("10")
      |> Enum.map(&parse_row/1)

    part1 =
      rows
      |> Enum.sum_by(fn {lights, buttons, _jolts} ->
        calculate_xors(lights, buttons, MapSet.new(buttons), 1)
      end)

    [part1: part1, part2: :wip]
  end

  defp parse_row(row) do
    row
    |> String.split(" ")
    |> Enum.reduce({0, [], %{}}, &parse_token/2)
  end

  defp parse_token("[" <> _rest = str, {0, buttons, jolts}) do
    lights =
      str
      |> String.slice(1..-2//1)
      |> String.graphemes()
      |> Stream.with_index()
      |> Enum.reduce(0, fn {char, idx}, acc ->
        if char == "." do
          acc
        else
          acc + Integer.pow(2, idx)
        end
      end)

    {lights, buttons, jolts}
  end

  defp parse_token("(" <> _rest = str, {lights, buttons, jolts}) do
    cur_buttons =
      str
      |> String.slice(1..-2//1)
      |> String.split(",")
      |> Enum.reduce(0, fn char, acc ->
        acc + Integer.pow(2, String.to_integer(char))
      end)

    {lights, [cur_buttons | buttons], jolts}
  end

  defp parse_token("{" <> _rest = str, {lights, buttons, %{}}) do
    {_, jolts} =
      str
      |> String.slice(1..-2//1)
      |> String.split(",")
      |> Enum.reduce({0, %{}}, fn char, {idx, cur_jolts} ->
        {idx + 1, Map.put(cur_jolts, idx, String.to_integer(char))}
      end)

    {lights, buttons, jolts}
  end

  defp calculate_xors(lights, buttons, cur_buttons, presses) do
    if MapSet.member?(cur_buttons, lights) do
      presses
    else
      new_buttons =
        cur_buttons
        |> Enum.reduce(MapSet.new(), fn x, acc ->
          buttons
          |> Enum.reduce(acc, fn y, cur_acc ->
            MapSet.put(cur_acc, Bitwise.bxor(x, y))
          end)
        end)

      calculate_xors(lights, buttons, new_buttons, presses + 1)
    end
  end
end
