defmodule NoMatterHowYouSliceIt do
  @doc """
  ## Examples

      iex> NoMatterHowYouSliceIt.overlaps_count([
      iex>   "#1 @ 1,3: 4x4",
      iex>   "#2 @ 3,1: 4x4",
      iex>   "#3 @ 5,5: 2x2",
      iex>   "#4 @ 4,4: 1x1",
      iex> ])
      4
  """
  def overlaps_count(claims) do
    claims
    |> overlaps()
    |> Enum.count()
  end

  @doc """
  ## Examples

      iex> NoMatterHowYouSliceIt.overlaps([
      iex>   "#1 @ 1,3: 4x4",
      iex>   "#2 @ 3,1: 4x4",
      iex>   "#3 @ 5,5: 2x2",
      iex>   "#4 @ 4,4: 1x1",
      iex> ])
      [{4, 4}, {4, 5}, {5, 4}, {5, 5}]
  """
  def overlaps(claims) do
    all =
      Enum.flat_map(claims, fn claim ->
        claim
        |> parse_claim()
        |> claim_coordinates()
      end)

    all
    |> Enum.reduce(%{}, & Map.update(&2, &1, 1, fn x -> x + 1 end))
    |> Enum.filter(fn {_k, v} -> v > 1 end)
    |> Enum.map(fn {k, _v} -> k end)
  end

  @doc """
  ## Examples

      iex> NoMatterHowYouSliceIt.parse_claim("#123 @ 3,2: 5x4")
      [{3, 2}, {5, 4}]
  """
  def parse_claim(claim) do
    [a, b, x, y] =
      Regex.run(
        ~r/#\d+ @ (\d+),(\d+): (\d+)x(\d+)/,
        claim, capture: :all_but_first
      )

    [
      {a |> String.to_integer(), b |> String.to_integer()},
      {x |> String.to_integer(), y |> String.to_integer()}
    ]
  end

  @doc """
  ## Examples

      iex> NoMatterHowYouSliceIt.claim_coordinates([{3, 2}, {5, 4}])
      [
        {4, 3}, {5, 3}, {6, 3}, {7, 3}, {8, 3},
        {4, 4}, {5, 4}, {6, 4}, {7, 4}, {8, 4},
        {4, 5}, {5, 5}, {6, 5}, {7, 5}, {8, 5},
        {4, 6}, {5, 6}, {6, 6}, {7, 6}, {8, 6},
      ]
  """
  def claim_coordinates([h | t]), do: claim_coordinates(h, hd(t))
  def claim_coordinates({a, b}, {n, m}) do
    {x, y}   = {a + 1, b + 1}
    {xz, yz} = {a + n, b + m}

    xx = Enum.to_list(x..xz)
    yy = Enum.to_list(y..yz)

    Enum.flat_map(yy, fn y ->
      Enum.map(xx, & {&1, y})
    end)
  end
end
