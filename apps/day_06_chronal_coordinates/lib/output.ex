defmodule ChronalCoordinates.Output do
  alias ChronalCoordinates.Input

  @doc """
  ## Examples

      iex> ChronalCoordinates.Output.part_one()
      6047
  """
  def part_one do
    ChronalCoordinates.finite_owner_coordinates_size(%Input{}.coordinates)
  end

  @doc """
  ## Examples

      iex> ChronalCoordinates.Output.part_two()
      46320
  """
  def part_two do
    ChronalCoordinates.safe_distance_size(%Input{}.coordinates, 10_000)
  end
end
