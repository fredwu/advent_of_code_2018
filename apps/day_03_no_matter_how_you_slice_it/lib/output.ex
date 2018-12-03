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

  @doc """
  ## Examples

      iex> NoMatterHowYouSliceIt.Output.part_two()
      331
  """
  def part_two do
    NoMatterHowYouSliceIt.id_without_overlaps(%Input{}.claims)
  end
end
