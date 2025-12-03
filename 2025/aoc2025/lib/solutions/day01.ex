defmodule Solutions.Day01 do
  @mod 100

  def solve do
    {_end_position, ended_zero_count, passed_zero_count} =
      Inputs.Parser.parse("01")
      |> Stream.map(&parse_instruction/1)
      |> Enum.reduce({50, 0, 0}, &process_instruction/2)

    [part1: ended_zero_count, part2: passed_zero_count]
  end

  defp parse_instruction("L" <> delta), do: -String.to_integer(delta)
  defp parse_instruction("R" <> delta), do: String.to_integer(delta)

  defp process_instruction(delta, {position, ended_zero_count, passed_zero_count}) do
    new_position = Integer.mod(position + delta, @mod)

    {
      new_position,
      ended_zero_count + if(new_position == 0, do: 1, else: 0),
      passed_zero_count + calculate_passed_zero_delta(position, delta)
    }
  end

  defp calculate_passed_zero_delta(position, delta) do
    # how many times _starting from zero_ rotating by delta will pass zero
    passed_zero_from_zero = div(abs(delta), @mod)

    # if we are "out of bounds", then we would have passed zero one additional time
    new_position_without_mod = position + rem(delta, @mod)
    passes_zero_from_position = new_position_without_mod <= 0 or new_position_without_mod >= @mod

    # note: don't double count the "starting from zero" case
    cond do
      position != 0 and passes_zero_from_position -> passed_zero_from_zero + 1
      true -> passed_zero_from_zero
    end
  end
end
