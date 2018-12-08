defmodule ChronalCoordinates do
  alias __MODULE__.{Coordinates, Distances, Owners}

  @doc """
  ## Examples

      iex> ChronalCoordinates.safe_distance_size([
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ], 32)
      16
  """
  def safe_distance_size(coordinates, safe_distance) do
    coordinates
    |> Coordinates.origin_max_coordinates()
    |> Coordinates.all_coordinates()
    |> Enum.filter(& Distances.coordinate_distance(&1, coordinates) < safe_distance)
    |> Enum.count()
  end

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
      |> Enum.group_by(fn {_, owner} -> owner end)
      |> Map.take(owners)
      |> Enum.sort_by(fn {_, items} -> Enum.count(items) end, &>=/2)
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
    boundary_coordinates =
      coordinates
      |> Coordinates.origin_max_coordinates()
      |> Coordinates.boundary_coordinates()

    infinite_owners =
      map
      |> Map.take(boundary_coordinates)
      |> Map.values()

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
    coordinates
    |> Coordinates.origin_max_coordinates()
    |> Coordinates.all_coordinates()
    |> Enum.into(%{}, fn {x, y} ->
      {{x, y}, Owners.coordinate_owner({x, y}, coordinates)}
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
    |> Owners.coordinates_with_owners()
    |> Map.values()
  end
end
