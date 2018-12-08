defmodule ChronalCoordinates.Distances do
  @doc """
  ## Examples

      iex> ChronalCoordinates.Distances.coordinate_distance({4, 3}, [
      iex>   {1, 1},
      iex>   {1, 6},
      iex>   {8, 3},
      iex>   {3, 4},
      iex>   {5, 5},
      iex>   {8, 9},
      iex> ])
      30
  """
  def coordinate_distance({x, y}, coordinates) do
    Enum.reduce(coordinates, 0, & coordinate_distance_from({x, y}, &1) + &2)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.Distances.coordinate_distance_from({4, 3}, {1, 1})
      5

      iex> ChronalCoordinates.Distances.coordinate_distance_from({4, 3}, {1, 6})
      6

      iex> ChronalCoordinates.Distances.coordinate_distance_from({4, 3}, {8, 3})
      4

      iex> ChronalCoordinates.Distances.coordinate_distance_from({4, 3}, {3, 4})
      2

      iex> ChronalCoordinates.Distances.coordinate_distance_from({4, 3}, {5, 5})
      3

      iex> ChronalCoordinates.Distances.coordinate_distance_from({4, 3}, {8, 9})
      10
  """
  def coordinate_distance_from({x, y}, {n, m}) do
    abs(x - n) + abs(y - m)
  end
end
