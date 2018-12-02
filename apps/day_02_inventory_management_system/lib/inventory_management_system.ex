defmodule InventoryManagementSystem do
  alias __MODULE__.Utils

  @doc """
  ## Examples

      iex> InventoryManagementSystem.common_letters([
      iex>   "abcde",
      iex>   "fghij",
      iex>   "klmno",
      iex>   "pqrst",
      iex>   "fguij",
      iex>   "axcye",
      iex>   "wvxyz",
      iex> ])
      "fgij"
  """
  def common_letters(box_ids) do
    {_n, str} =
      box_ids
      |> Utils.combination(2)
      |> Enum.map(&simple_levenshtein_distance/1)
      |> Enum.find(fn {n, _str} -> n == 1 end)

    str
  end

  @doc """
  ## Examples

      iex> InventoryManagementSystem.simple_levenshtein_distance(["abcde", "axcye"])
      {2, "ace"}

      iex> InventoryManagementSystem.simple_levenshtein_distance("abcde", "axcye")
      {2, "ace"}

      iex> InventoryManagementSystem.simple_levenshtein_distance("fghij", "fguij")
      {1, "fgij"}
  """
  def simple_levenshtein_distance([h | t]), do: simple_levenshtein_distance(h, hd(t))
  def simple_levenshtein_distance(a, b) do
    a = a |> String.split("", trim: true)
    b = b |> String.split("", trim: true)

    [a, b]
    |> Enum.zip()
    |> Enum.reduce({0, ""}, fn {x, y}, {n, str} ->
      case x == y do
        true  -> {n, str <> x}
        false -> {n + 1, str}
      end
    end)
  end

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
  def checksum(box_ids) do
    counts   = Enum.flat_map(box_ids, &scan/1)
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
    |> Enum.reduce(%{}, & Map.update(&2, &1, 1, fn n -> n + 1 end))
    |> Map.values()
    |> Enum.filter(& &1 in [2, 3])
    |> Enum.uniq()
  end
end
