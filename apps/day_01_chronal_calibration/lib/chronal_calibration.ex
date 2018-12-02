defmodule ChronalCalibration do
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

  @doc """
  ## Examples

      iex> ChronalCalibration.first_repeats([+1, -1])
      0

      iex> ChronalCalibration.first_repeats([+3, +3, +4, -2, -4])
      10

      iex> ChronalCalibration.first_repeats([-6, +3, +8, +5, -6])
      5

      iex> ChronalCalibration.first_repeats([+7, +7, -2, -7, -4])
      14
  """
  def first_repeats(frequencies) do
    find_repeats([0], [], frequencies)
  end

  defp find_repeats(results, [], frequencies) do
    find_repeats(results, frequencies, frequencies)
  end

  defp find_repeats(results, [head | tail], frequencies) do
    result = hd(results) + head

    if result in results do
      result
    else
      find_repeats([result] ++ results, tail, frequencies)
    end
  end
end
