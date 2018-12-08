defmodule ChronalCoordinates.Coordinates do
  @doc """
  ## Examples

      iex> ChronalCoordinates.Coordinates.boundary_coordinates({{2, 1}, {4, 3}})
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
  def boundary_coordinates({{x, y} = _origin, {n, m} = _max}) do
    top    = all_coordinates({{x, y}, {n, y}})
    right  = all_coordinates({{n, y}, {n, m}})
    bottom = all_coordinates({{x, m}, {n, m}})
    left   = all_coordinates({{x, y}, {x, m}})

    Enum.uniq(top ++ right ++ bottom ++ left)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.Coordinates.all_coordinates({{2, 1}, {3, 4}})
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
  def all_coordinates({{x, y} = _origin, {n, m} = _max}) do
    i = (n - x + 1) * (m - y + 1)

    Enum.reduce(1..i, [{n, m}], fn
      _, [{a, b}  | _] = acc when a > x -> [{a - 1, b} | acc]
      _, [{_a, b} | _] = acc when b > y -> [{n, b - 1} | acc]
      _, acc                            -> acc
    end)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.Coordinates.origin_max_coordinates([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      {{1, 1}, {8, 9}}
  """
  def origin_max_coordinates(coordinates) do
    {
      coordinates |> origin_coordinates(),
      coordinates |> max_coordinates(),
    }
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.Coordinates.origin_coordinates([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      {1, 1}

      iex> ChronalCoordinates.Coordinates.origin_coordinates([
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

      iex> ChronalCoordinates.Coordinates.max_coordinates([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      {8, 9}

      iex> ChronalCoordinates.Coordinates.max_coordinates([
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

      iex> ChronalCoordinates.Coordinates.coordinates_by_distance({0, 0}, 0)
      [{0, 0}]

      iex> ChronalCoordinates.Coordinates.coordinates_by_distance({0, 0}, 1) |> Enum.sort()
      [
        {0, 1},
        {1, 0}
      ]

      iex> ChronalCoordinates.Coordinates.coordinates_by_distance({2, 2}, 3) |> Enum.sort()
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

      iex> ChronalCoordinates.Coordinates.coordinate_deltas(1) |> Enum.sort()
      [
        {-1, 0},
        {0, -1},
        {0, 1},
        {1, 0},
      ]

      iex> ChronalCoordinates.Coordinates.coordinate_deltas(2) |> Enum.sort()
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

      iex> ChronalCoordinates.Coordinates.coordinate_deltas(3) |> Enum.sort()
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
