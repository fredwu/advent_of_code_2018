defmodule ChronalCoordinates do
  @max_seeking_distance 1_000

  @doc """
  ## Examples

      iex> ChronalCoordinates.finite_owner_coordinates_size([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      17
  """
  def finite_owner_coordinates_size(coordinates) do
    map    = map(coordinates)
    owners = finite_owners(coordinates, map)

    {_owner, owner_coordinates} =
      map
      |> Enum.filter(fn {_, owner} -> Enum.member?(owners, owner) end)
      |> Enum.group_by(fn {_, owner} -> owner end)
      |> Enum.sort_by(fn {_, count} -> count end, &>=/2)
      |> hd()

    Enum.count(owner_coordinates)
  end

  @doc """
  ## Examples

      iex> map = ChronalCoordinates.map([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      iex>
      iex> ChronalCoordinates.finite_owners([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ], map)
      ["4", "5"]
  """
  def finite_owners(coordinates, map) do
    origin = coordinates |> origin_coordinates()
    max    = coordinates |> max_coordinates()

    boundary_coordinates = boundary_coordinates(origin, max)

    infinite_owners =
      map
      |> Map.take(boundary_coordinates)
      |> Map.values()
      |> Enum.uniq()
      |> List.delete(".")

    coordinates
    |> map_owners()
    |> Kernel.--(infinite_owners)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.map([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      %{
        {1, 1} => "1",
        {2, 1} => "1",
        {3, 1} => "1",
        {4, 1} => "1",
        {5, 1} => ".",
        {6, 1} => "3",
        {7, 1} => "3",
        {8, 1} => "3",
        {1, 2} => "1",
        {2, 2} => "1",
        {3, 2} => "4",
        {4, 2} => "4",
        {5, 2} => "5",
        {6, 2} => "3",
        {7, 2} => "3",
        {8, 2} => "3",
        {1, 3} => "1",
        {2, 3} => "4",
        {3, 3} => "4",
        {4, 3} => "4",
        {5, 3} => "5",
        {6, 3} => "3",
        {7, 3} => "3",
        {8, 3} => "3",
        {1, 4} => ".",
        {2, 4} => "4",
        {3, 4} => "4",
        {4, 4} => "4",
        {5, 4} => "5",
        {6, 4} => "5",
        {7, 4} => "3",
        {8, 4} => "3",
        {1, 5} => "2",
        {2, 5} => ".",
        {3, 5} => "4",
        {4, 5} => "5",
        {5, 5} => "5",
        {6, 5} => "5",
        {7, 5} => "5",
        {8, 5} => "3",
        {1, 6} => "2",
        {2, 6} => "2",
        {3, 6} => ".",
        {4, 6} => "5",
        {5, 6} => "5",
        {6, 6} => "5",
        {7, 6} => "5",
        {8, 6} => ".",
        {1, 7} => "2",
        {2, 7} => "2",
        {3, 7} => ".",
        {4, 7} => "5",
        {5, 7} => "5",
        {6, 7} => "5",
        {7, 7} => "6",
        {8, 7} => "6",
        {1, 8} => "2",
        {2, 8} => "2",
        {3, 8} => ".",
        {4, 8} => "5",
        {5, 8} => "5",
        {6, 8} => "6",
        {7, 8} => "6",
        {8, 8} => "6",
        {1, 9} => "2",
        {2, 9} => "2",
        {3, 9} => ".",
        {4, 9} => "6",
        {5, 9} => "6",
        {6, 9} => "6",
        {7, 9} => "6",
        {8, 9} => "6",
      }
  """
  def map(coordinates) do
    origin = coordinates |> origin_coordinates()
    max    = coordinates |> max_coordinates()

    origin
    |> all_coordinates(max)
    |> Enum.into(%{}, fn {x, y} ->
      {{x, y}, coordinate_owner({x, y}, coordinates)}
    end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.coordinate_owner({1, 1}, [
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      "1"

      iex> ChronalCoordinates.coordinate_owner({2, 5}, [
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      "."

      iex> ChronalCoordinates.coordinate_owner({4, 2}, [
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      "4"
  """
  def coordinate_owner({x, y}, coordinates) do
    coordinates_with_owners = coordinates_with_owners(coordinates)

    0..@max_seeking_distance
    |> Enum.reduce_while([], fn distance, acc ->
      owner_fanout_coordinates = coordinates_by_distance({x, y}, distance)

      case owner_fanout_coordinates -- (owner_fanout_coordinates -- coordinates) do
        [] -> {:cont, acc}
        found_coordinates ->
          owners =
            found_coordinates
            |> Enum.map(&Map.get(coordinates_with_owners, &1))
            |> Enum.uniq()

          case Enum.count(owners) do
            1 -> {:halt, hd(owners)}
            _ -> {:halt, "."}
          end
      end
    end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.map_owners([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ]) |> Enum.sort()
      ["1", "2", "3", "4", "5", "6"]
  """
  def map_owners(coordinates) do
    coordinates
    |> coordinates_with_owners()
    |> Map.values()
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.coordinates_with_owners([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      %{
        {1, 1} => "1",
        {1, 6} => "2",
        {8, 3} => "3",
        {3, 4} => "4",
        {5, 5} => "5",
        {8, 9} => "6",
      }
  """
  def coordinates_with_owners(coordinates) do
    coordinates
    |> Enum.with_index()
    |> Enum.into(%{}, fn {k, v} -> {k, Integer.to_string(v + 1)} end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.boundary_coordinates({2, 1}, {4, 3})
      [
        {2, 1},
        {3, 1},
        {4, 1},
        {4, 2},
        {4, 3},
        {2, 3},
        {3, 3},
        {2, 2},
      ]
  """
  def boundary_coordinates({x, y} = _origin, {n, m} = _max) do
    top    = all_coordinates({x, y}, {n, y})
    right  = all_coordinates({n, y}, {n, m})
    bottom = all_coordinates({x, m}, {n, m})
    left   = all_coordinates({x, y}, {x, m})

    Enum.uniq(top ++ right ++ bottom ++ left)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.all_coordinates({2, 1}, {3, 4})
      [
        {2, 1},
        {3, 1},
        {2, 2},
        {3, 2},
        {2, 3},
        {3, 3},
        {2, 4},
        {3, 4},
      ]
  """
  def all_coordinates({x, y} = _origin, {n, m} = _max) do
    i = (n - x + 1) * (m - y + 1)

    Enum.reduce(1..i, [{n, m}], fn
      _, [{a, b}  | _] = acc when a > x -> [{a - 1, b} | acc]
      _, [{_a, b} | _] = acc when b > y -> [{n, b - 1} | acc]
      _, acc                            -> acc
    end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.origin_coordinates([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      {1, 1}

      iex> ChronalCoordinates.origin_coordinates([
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex> ])
      {1, 3}
  """
  def origin_coordinates(coordinates) do
    Enum.reduce(coordinates, fn
      {n, m},   {x, y} when n < x and m < y -> {n, m}
      {n, _m},  {x, y} when n < x           -> {n, y}
      {_n, m},  {x, y} when m < y           -> {x, m}
      {_n, _m}, {x, y}                      -> {x, y}
    end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.max_coordinates([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      {8, 9}

      iex> ChronalCoordinates.max_coordinates([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex> ])
      {8, 6}
  """
  def max_coordinates(coordinates) do
    Enum.reduce(coordinates, fn
      {n, m},   {x, y} when n > x and m > y -> {n, m}
      {n, _m},  {x, y} when n > x           -> {n, y}
      {_n, m},  {x, y} when m > y           -> {x, m}
      {_n, _m}, {x, y}                      -> {x, y}
    end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.coordinates_by_distance({0, 0}, 0)
      [{0, 0}]

      iex> ChronalCoordinates.coordinates_by_distance({0, 0}, 1) |> Enum.sort()
      [
        {0, 1},
        {1, 0}
      ]

      iex> ChronalCoordinates.coordinates_by_distance({2, 2}, 3) |> Enum.sort()
      [
        {0, 1},
        {0, 3},
        {1, 0},
        {1, 4},
        {2, 5},
        {3, 0},
        {3, 4},
        {4, 1},
        {4, 3},
        {5, 2},
      ]
  """
  def coordinates_by_distance({x, y}, distance) do
    distance
    |> coordinate_deltas()
    |> Enum.map(fn {n, m} ->
      a = x + n
      b = y + m

      if a >= 0 && b >= 0 do
        {a, b}
      end
    end)
    |> Enum.reject(& &1 == nil)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.coordinate_deltas(1) |> Enum.sort()
      [
        {-1, 0},
        {0, -1},
        {0, 1},
        {1, 0},
      ]

      iex> ChronalCoordinates.coordinate_deltas(2) |> Enum.sort()
      [
        {-2, 0},
        {-1, -1},
        {-1, 1},
        {0, -2},
        {0, 2},
        {1, -1},
        {1, 1},
        {2, 0},
      ]

      iex> ChronalCoordinates.coordinate_deltas(3) |> Enum.sort()
      [
        {-3, 0},
        {-2, -1},
        {-2, 1},
        {-1, -2},
        {-1, 2},
        {0, -3},
        {0, 3},
        {1, -2},
        {1, 2},
        {2, -1},
        {2, 1},
        {3, 0},
      ]
  """
  def coordinate_deltas(distance) do
    0..distance
    |> Enum.flat_map(fn x ->
      y = distance - x

      MapSet.new()
      |> MapSet.put({x, -y})
      |> MapSet.put({x, y})
      |> MapSet.put({-x, y})
      |> MapSet.put({-x, -y})
    end)
  end
end
