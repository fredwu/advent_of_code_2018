defmodule AlchemicalReduction do
  @codepoint_delta 32

  @doc """
  ## Examples

      iex> AlchemicalReduction.units("dabCBAcaDA")
      10
  """
  def units(polymer) do
    polymer
    |> react()
    |> String.length()
  end

  @doc """
  ## Examples

      iex> AlchemicalReduction.react("dabAcCaCBAcCcaDA")
      "dabCBAcaDA"
  """
  def react(polymer) do
    polymer
    |> String.codepoints()
    |> scan()
  end

  @doc """
  ## Examples

      iex> AlchemicalReduction.scan([
      iex>   "d", "a", "b", "A", "c", "C", "a", "C", "B", "A", "c", "C", "c", "a", "D", "A"
      iex> ])
      "dabCBAcaDA"
  """
  def scan(tokens) do
    {reduced_tokens, found} =
      Enum.reduce(tokens, {[], 0}, fn
        n, {[], _} ->
          {[n], 1}

        n, {[m | rest] = t, found} ->
          if reactive?(n, m) do
            {rest, found + 1}
          else
            {[n | t], found}
          end
      end)

    if found > 1 do
      scan(reduced_tokens)
    else
      tokens
      |> Enum.reverse()
      |> Enum.join()
    end
  end

  @doc """
  ## Examples

      iex> AlchemicalReduction.reactive?("a", "A")
      true

      iex> AlchemicalReduction.reactive?("A", "a")
      true

      iex> AlchemicalReduction.reactive?("a", "a")
      false

      iex> AlchemicalReduction.reactive?("a", "b")
      false
  """
  def reactive?(a, b) do
    <<a>> = a
    <<b>> = b

    abs(a - b) == @codepoint_delta
  end
end
