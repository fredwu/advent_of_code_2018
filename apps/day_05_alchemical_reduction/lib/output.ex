defmodule AlchemicalReduction.Output do
  alias AlchemicalReduction.Input

  @doc """
  ## Examples

      iex> AlchemicalReduction.Output.part_one()
      9288
  """
  def part_one do
    AlchemicalReduction.units(%Input{}.polymer)
  end
end
