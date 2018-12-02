defmodule InventoryManagementSystem.Utils do
  @doc """

  See: https://rosettacode.org/wiki/Combinations#Elixir

  ## Examples

      iex> InventoryManagementSystem.Utils.combination([1, 2, 3], 2)
      [[1, 2], [1, 3], [2, 3]]
  """
  def combination(_, 0), do: [[]]
  def combination([], _), do: []
  def combination([h | t], n) do
    (for l <- combination(t, n - 1), do: [h | l]) ++ combination(t, n)
  end
end
