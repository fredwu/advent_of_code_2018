defmodule ChronalCalibration do
  alias ChronalCalibration.Input

  @doc """
  ## Examples

      iex> ChronalCalibration.output()
      599
  """
  def output do
    calibrate(%Input{}.frequencies)
  end

  @doc """
  ## Examples

      iex> ChronalCalibration.calibrate([+1, +1, +1])
      3

      iex> ChronalCalibration.calibrate([+1, +1, -2])
      0

      iex> ChronalCalibration.calibrate([-1, -2, -3])
      -6
  """
  defdelegate calibrate(frequencies), to: Enum, as: :sum
end
