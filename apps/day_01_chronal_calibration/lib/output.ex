defmodule ChronalCalibration.Output do
  alias ChronalCalibration.Input

  @doc """
  ## Examples

      iex> ChronalCalibration.Output.part_one()
      599
  """
  def part_one do
    ChronalCalibration.calibrate(%Input{}.frequencies)
  end

  @doc """
  ## Examples

      iex> ChronalCalibration.Output.part_two()
      81204
  """
  def part_two do
    ChronalCalibration.first_repeats(%Input{}.frequencies)
  end
end
