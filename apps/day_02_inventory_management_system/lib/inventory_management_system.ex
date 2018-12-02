defmodule InventoryManagementSystem do
  @doc """
  ## Examples

      iex> InventoryManagementSystem.checksum([
      iex>   "abcdef",
      iex>   "bababc",
      iex>   "abbcde",
      iex>   "abcccd",
      iex>   "aabcdd",
      iex>   "abcdee",
      iex>   "ababab",
      iex> ])
      12
  """
  def checksum(ids) do
    counts   = Enum.flat_map(ids, &scan/1)
    count_2s = Enum.count(counts, & &1 == 2)
    count_3s = Enum.count(counts, & &1 == 3)

    count_2s * count_3s
  end

  @doc """
  ## Examples

      iex> InventoryManagementSystem.scan("abcdef")
      []

      iex> InventoryManagementSystem.scan("bababc")
      [2, 3]

      iex> InventoryManagementSystem.scan("abbcde")
      [2]

      iex> InventoryManagementSystem.scan("abcccd")
      [3]

      iex> InventoryManagementSystem.scan("aabcdd")
      [2]

      iex> InventoryManagementSystem.scan("abcdee")
      [2]

      iex> InventoryManagementSystem.scan("ababab")
      [3]
  """
  def scan(id) do
    id
    |> String.graphemes()
    |> Enum.reduce(%{}, fn n, acc ->
      Map.update(acc, n, 1, & &1 + 1)
    end)
    |> Map.values()
    |> Enum.filter(& &1 in [2, 3])
    |> Enum.uniq()
  end
end
