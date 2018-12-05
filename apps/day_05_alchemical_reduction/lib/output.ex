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

  @doc """
  ## Examples

      iex> AlchemicalReduction.Output.part_two()
      5844
  """
  def part_two do
    AlchemicalReduction.units_sans_one_type(%Input{}.polymer)
  end
end
