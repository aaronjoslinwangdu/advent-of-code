defmodule Solutions.Day03 do
  @desired_battery_count 12

  def solve do
    Inputs.Parser.parse("03")
    |> Stream.map(&process_bank(&1))
    |> Enum.sum()
  end

  defp process_bank(bank) do
    total_batteries = String.length(bank)

    String.graphemes(bank)
    |> Stream.map(&String.to_integer/1)
    |> Enum.with_index()
    |> Enum.reduce([], fn battery, stack ->
      choose_batteries(stack, battery, total_batteries)
    end)
    |> Enum.reverse()
    |> Enum.reduce(fn digit, acc -> acc * 10 + digit end)
  end

  def choose_batteries(stack, {battery, index}, total_batteries) do
    stack
    |> remove_smaller_batteries(battery, total_batteries - index)
    |> maybe_push(battery)
  end

  def remove_smaller_batteries(stack, battery, remaining_batteries) do
    case stack do
      [smallest_battery | rest] when smallest_battery < battery ->
        batteries_needed = @desired_battery_count - length(stack) + 1

        if remaining_batteries >= batteries_needed do
          remove_smaller_batteries(rest, battery, remaining_batteries)
        else
          stack
        end

      _ ->
        stack
    end
  end

  def maybe_push(stack, battery) do
    if length(stack) < @desired_battery_count do
      [battery | stack]
    else
      stack
    end
  end
end
