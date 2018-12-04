defmodule ReposeRecord.Output do
  alias ReposeRecord.Input

  @doc """
  ## Examples

      iex> ReposeRecord.Output.part_one()
      143415
  """
  def part_one do
    ReposeRecord.lazy_number(%Input{}.records)
  end

  @doc """
  ## Examples

      iex> ReposeRecord.Output.part_two()
      49944
  """
  def part_two do
    ReposeRecord.lazy_minute_number(%Input{}.records)
  end
end
