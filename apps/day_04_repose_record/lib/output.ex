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
end
