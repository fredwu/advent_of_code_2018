defmodule InventoryManagementSystem.Output do
  alias InventoryManagementSystem.Input

  @doc """
  ## Examples

      iex> InventoryManagementSystem.Output.part_one()
      5952
  """
  def part_one do
    InventoryManagementSystem.checksum(%Input{}.box_ids)
  end
end
