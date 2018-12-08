defmodule ChronalCoordinates.Owners do
  alias ChronalCoordinates.Coordinates

  @max_seeking_distance 1_000

  @doc """
  ## Examples

      iex> ChronalCoordinates.Owners.coordinate_owner({1, 1}, [
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      "1"

      iex> ChronalCoordinates.Owners.coordinate_owner({2, 5}, [
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      "."

      iex> ChronalCoordinates.Owners.coordinate_owner({4, 2}, [
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
      owner_fanout_coordinates = Coordinates.coordinates_by_distance({x, y}, distance)

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

      iex> ChronalCoordinates.Owners.coordinates_with_owners([
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
end
