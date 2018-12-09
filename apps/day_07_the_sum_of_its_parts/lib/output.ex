defmodule TheSumOfItsParts.Output do
  alias TheSumOfItsParts.Input

  @doc """
  ## Examples

      iex> TheSumOfItsParts.Output.part_one()
      "GNJOCHKSWTFMXLYDZABIREPVUQ"
  """
  def part_one do
    TheSumOfItsParts.order(%Input{}.instructions)
  end
end
