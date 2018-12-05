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

      iex> AlchemicalReduction.units_sans_one_type("dabCBAcaDA")
      4
  """
  def units_sans_one_type(polymer) do
    unit_types()
    |> Enum.map(& units_by(polymer, &1))
    |> Enum.min()
  end

  @doc """
  ## Examples

      iex> AlchemicalReduction.units_by("dabAcCaCBAcCcaDA", ["A", "a"])
      6

      iex> AlchemicalReduction.units_by("dabAcCaCBAcCcaDA", ["B", "b"])
      8

      iex> AlchemicalReduction.units_by("dabAcCaCBAcCcaDA", ["C", "c"])
      4

      iex> AlchemicalReduction.units_by("dabAcCaCBAcCcaDA", ["D", "d"])
      6
  """
  def units_by(polymer, units) do
    polymer
    |> fully_react_by(units)
    |> String.length()
  end

  @doc """
  ## Examples

      iex> AlchemicalReduction.fully_react_by("dabAcCaCBAcCcaDA", ["A", "a"])
      "dbCBcD"

      iex> AlchemicalReduction.fully_react_by("dabAcCaCBAcCcaDA", ["B", "b"])
      "daCAcaDA"

      iex> AlchemicalReduction.fully_react_by("dabAcCaCBAcCcaDA", ["C", "c"])
      "daDA"

      iex> AlchemicalReduction.fully_react_by("dabAcCaCBAcCcaDA", ["D", "d"])
      "abCBAc"
  """
  def fully_react_by(polymer, units) do
    polymer
    |> react_by(units)
    |> react()
  end

  @doc """
  ## Examples

      iex> AlchemicalReduction.react_by("dabAcCaCBAcCcaDA", ["A", "a"])
      "dbcCCBcCcD"

      iex> AlchemicalReduction.react_by("dabAcCaCBAcCcaDA", ["B", "b"])
      "daAcCaCAcCcaDA"

      iex> AlchemicalReduction.react_by("dabAcCaCBAcCcaDA", ["C", "c"])
      "dabAaBAaDA"

      iex> AlchemicalReduction.react_by("dabAcCaCBAcCcaDA", ["D", "d"])
      "abAcCaCBAcCcaA"
  """
  def react_by(polymer, units) do
    polymer
    |> String.codepoints()
    |> Enum.reject(& Enum.member?(units, &1))
    |> Enum.join()
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

  @doc """
  ## Examples

      iex> AlchemicalReduction.unit_types() |> Enum.slice(0..1)
      [
        ["a", "A"],
        ["b", "B"],
      ]
  """
  def unit_types do
    a = ?a..?z |> Enum.to_list() |> Enum.map(&List.to_string([&1]))
    b = ?A..?Z |> Enum.to_list() |> Enum.map(&List.to_string([&1]))

    a
    |> Enum.zip(b)
    |> Enum.map(&Tuple.to_list/1)
  end
end
