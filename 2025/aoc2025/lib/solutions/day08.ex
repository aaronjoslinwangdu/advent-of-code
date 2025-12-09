defmodule Solutions.Day08 do
  def solve do
    coordinates =
      Inputs.Parser.parse("08")
      |> Stream.map(fn row ->
        row
        |> String.split(",")
        |> Enum.map(&String.to_integer/1)
        |> List.to_tuple()
      end)
      |> Stream.with_index()
      |> Enum.reduce(%{}, fn {coordinate, node}, acc -> Map.put(acc, node, coordinate) end)

    node_count = map_size(coordinates)

    node_distances =
      0..(node_count - 2)
      |> Enum.reduce(%{}, fn u, acc ->
        (u + 1)..(node_count - 1)
        |> Enum.reduce(acc, fn v, row_acc ->
          Map.put(
            row_acc,
            {u, v},
            calculate_distance(Map.get(coordinates, u), Map.get(coordinates, v))
          )
        end)
      end)
      |> Stream.map(fn {nodes, dist} -> {dist, nodes} end)
      |> Enum.sort()

    [
      part1: Solutions.Day08.Part1.solve(node_distances, node_count),
      part2: Solutions.Day08.Part2.solve(node_distances, node_count, coordinates)
    ]
  end

  defp calculate_distance({x1, y1, z1}, {x2, y2, z2}) do
    x = Integer.pow(x1 - x2, 2)
    y = Integer.pow(y1 - y2, 2)
    z = Integer.pow(z1 - z2, 2)
    :math.sqrt(x + y + z)
  end
end

defmodule Solutions.Day08.Part1 do
  def solve(node_distances, node_count) do
    {_disjoint_set, group_sizes} =
      node_distances
      |> Enum.take(1000)
      |> Enum.reduce(DisjointSet.new(node_count), fn {_, {u, v}}, disjoint_set ->
        DisjointSet.union(disjoint_set, u, v)
      end)
      |> DisjointSet.group_sizes()

    group_sizes
    |> Map.values()
    |> Enum.sort(:desc)
    |> Stream.take(3)
    |> Enum.product()
  end
end

defmodule Solutions.Day08.Part2 do
  def solve(node_distances, node_count, coordinates) do
    node_distances
    |> Enum.reduce_while(DisjointSet.new(node_count), fn {_dist, {u, v}}, disjoint_set ->
      unioned_disjoint_set = DisjointSet.union(disjoint_set, u, v)
      {new_disjoint_set, group_sizes} = DisjointSet.group_sizes(unioned_disjoint_set)

      if map_size(group_sizes) == 1 do
        {:halt, [u, v]}
      else
        {:cont, new_disjoint_set}
      end
    end)
    |> Stream.map(fn node ->
      {x, _y, _z} = Map.get(coordinates, node)
      x
    end)
    |> Enum.product()
  end
end

defmodule DisjointSet do
  defstruct parents: %{}, ranks: %{}

  def new(node_count) do
    range = 0..(node_count - 1)

    parents =
      range
      |> Enum.reduce(%{}, fn node, acc -> Map.put(acc, node, node) end)

    ranks =
      range
      |> Enum.reduce(%{}, fn node, acc -> Map.put(acc, node, 1) end)

    %__MODULE__{
      parents: parents,
      ranks: ranks
    }
  end

  def find(disjoint_set = %__MODULE__{}, node) do
    %__MODULE__{parents: parents} = disjoint_set

    case Map.get(parents, node) do
      ^node ->
        {disjoint_set, node}

      parent ->
        {updated_disjoint_set = %__MODULE__{}, root} = find(disjoint_set, parent)
        %__MODULE__{parents: updated_parents} = updated_disjoint_set

        new_parents = Map.put(updated_parents, node, root)
        new_disjoint_set = %__MODULE__{updated_disjoint_set | parents: new_parents}

        {new_disjoint_set, root}
    end
  end

  def union(%__MODULE__{} = disjoint_set, u, v) do
    {placeholder, root1} = find(disjoint_set, u)
    {new_disjoint_set = %__MODULE__{}, root2} = find(placeholder, v)

    if root1 == root2 do
      new_disjoint_set
    else
      %__MODULE__{ranks: ranks, parents: parents} = new_disjoint_set

      rank1 = Map.get(ranks, root1)
      rank2 = Map.get(ranks, root2)

      cond do
        rank1 > rank2 ->
          new_parents = Map.put(parents, root2, root1)
          %__MODULE__{new_disjoint_set | parents: new_parents}

        rank1 < rank2 ->
          new_parents = Map.put(parents, root1, root2)
          %__MODULE__{new_disjoint_set | parents: new_parents}

        rank1 == rank2 ->
          new_parents = Map.put(parents, root2, root1)
          new_ranks = Map.put(ranks, root1, rank1 + 1)
          %__MODULE__{parents: new_parents, ranks: new_ranks}
      end
    end
  end

  def group_sizes(%__MODULE__{parents: parents} = disjoint_set) do
    parents
    |> Enum.reduce({disjoint_set, %{}}, fn {node, _parent}, {disjoint_set_acc, root_acc} ->
      {new_disjoint_set, root} = find(disjoint_set_acc, node)

      case Map.get(root_acc, root) do
        nil -> {new_disjoint_set, Map.put(root_acc, root, 1)}
        children -> {new_disjoint_set, Map.put(root_acc, root, children + 1)}
      end
    end)
  end
end
