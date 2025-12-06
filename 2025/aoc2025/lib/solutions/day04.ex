defmodule Solutions.Day04 do
  # mutating multi-dimensional arrays and tuples sucks big time or i'm just a noob
  # todo: look into https://hexdocs.pm/arrays/Arrays.html

  def solve do
    Grid.start()

    Inputs.Parser.parse("04")
    |> Stream.with_index()
    |> Enum.each(fn {row, i} ->
      String.graphemes(row)
      |> Stream.with_index()
      |> Enum.each(fn {value, j} -> Grid.put({i, j}, value) end)
    end)

    [part1: Solutions.Day04.Part1.solve(), part2: Solutions.Day04.Part2.solve()]
  end
end

defmodule Solutions.Day04.Part1 do
  def solve do
    Grid.keys()
    |> Enum.reduce(0, fn key, valid_cell_count ->
      if Grid.can_access_paper(key) do
        valid_cell_count + 1
      else
        valid_cell_count
      end
    end)
  end
end

defmodule Solutions.Day04.Part2 do
  def solve do
    calculate_valid_cell_count(0, 69420)
  end

  # recursively calculate _until_ no new valid cells are marked
  defp calculate_valid_cell_count(count, 0), do: count

  defp calculate_valid_cell_count(count, _previous_result) do
    valid_cell_count =
      Grid.keys()
      |> Enum.reduce(0, fn key, valid_cell_count ->
        if Grid.can_access_paper(key) do
          Grid.put(key, "X")
          valid_cell_count + 1
        else
          valid_cell_count
        end
      end)

    calculate_valid_cell_count(count + valid_cell_count, valid_cell_count)
  end
end

defmodule Grid do
  @directions [{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {1, -1}, {0, -1}, {-1, -1}]

  use GenServer

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  def keys, do: GenServer.call(__MODULE__, :keys)
  def can_access_paper(key), do: GenServer.call(__MODULE__, {:can_access_paper, key})

  @impl GenServer
  def init(_) do
    {:ok, %{}}
  end

  @impl GenServer
  def handle_call({:get, key}, _, grid) do
    {:reply, Map.get(grid, key), grid}
  end

  def handle_call(:keys, _, grid) do
    {:reply, Map.keys(grid), grid}
  end

  def handle_call({:can_access_paper, {i, j}}, _, grid) do
    if Map.get(grid, {i, j}) == "@" do
      adjacent_paper =
        for {di, dj} <- @directions do
          if Map.get(grid, {i + di, j + dj}) == "@" do
            1
          else
            0
          end
        end
        |> Enum.sum()

      {:reply, adjacent_paper < 4, grid}
    else
      {:reply, false, grid}
    end
  end

  @impl GenServer
  def handle_cast({:put, {i, j}, value}, grid) do
    {:noreply, Map.put(grid, {i, j}, value)}
  end
end
