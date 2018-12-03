defmodule NoMatterHowYouSliceIt.Output do
  alias NoMatterHowYouSliceIt.Input

  @doc """
  ## Examples

      iex> NoMatterHowYouSliceIt.Output.part_one()
      98005
  """
  def part_one do
    NoMatterHowYouSliceIt.overlaps_count(%Input{}.claims)
  end
end
