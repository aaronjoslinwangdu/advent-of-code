defmodule Grid do
  use GenServer

  def start, do: GenServer.start(__MODULE__, nil, name: __MODULE__)
  def get(key), do: GenServer.call(__MODULE__, {:get, key})
  def put(key, value), do: GenServer.cast(__MODULE__, {:put, key, value})
  def length, do: GenServer.call(__MODULE__, :length)
  def width, do: GenServer.call(__MODULE__, :width)
  def keys, do: GenServer.call(__MODULE__, :keys)
  def print, do: GenServer.call(__MODULE__, :print)

  @impl GenServer
  def init(_) do
    {:ok, {%{}, 0, 0}}
  end

  @impl GenServer
  def handle_call({:get, key}, _, {grid, length, width}) do
    {:reply, Map.get(grid, key), {grid, length, width}}
  end

  def handle_call(:length, _, {grid, length, width}) do
    {:reply, length, {grid, length, width}}
  end

  def handle_call(:width, _, {grid, length, width}) do
    {:reply, width, {grid, length, width}}
  end

  def handle_call(:print, _, {grid, length, width}) do
    IO.inspect(grid)
    {:reply, :ok, {grid, length, width}}
  end

  def handle_call(:keys, _, {grid, length, width}) do
    {:reply, Map.keys(grid), {grid, length, width}}
  end

  @impl GenServer
  def handle_cast({:put, {i, j}, value}, {grid, length, width}) do
    {:noreply, {Map.put(grid, {i, j}, value), max(length, i), max(width, j)}}
  end
end

defmodule Solutions.Day04 do
  @directions [{1, 0}, {1, 1}, {0, 1}, {-1, 1}, {-1, 0}, {1, -1}, {0, -1}, {-1, -1}]

  def solve do
    Grid.start()

    Inputs.Parser.parse("test")
    |> Stream.with_index()
    |> Enum.each(fn {row, i} ->
      String.graphemes(row)
      |> Stream.with_index()
      |> Enum.each(fn {value, j} ->
        Grid.put({i, j}, value)
      end)
    end)

    Grid.keys()
    |> Enum.reduce(0, fn {i, j}, invalid ->
      if Grid.get({i, j}) == "@" do
        invalid + is_valid_cell(i, j)
      else
        invalid
      end
    end)
  end

  defp is_valid_cell(i, j) do
    adjacent =
      for {di, dj} <- @directions do
        if Grid.get({i + di, j + dj}) == "@" do
          1
        else
          0
        end
      end
      |> Enum.sum()

    if adjacent < 4 do
      1
    else
      0
    end
  end
end
