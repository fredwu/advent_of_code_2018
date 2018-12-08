defmodule ChronalCoordinates.Output do
  alias ChronalCoordinates.Input

  @doc """
  ## Examples

      iex> ChronalCoordinates.Output.part_one()
      3894
  """
  def part_one do
    ChronalCoordinates.finite_owner_coordinates_size(%Input{}.coordinates)
  end
end
