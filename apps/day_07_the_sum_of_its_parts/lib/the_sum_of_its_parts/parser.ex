defmodule TheSumOfItsParts.Parser do
  @doc """
  ## Examples

      iex> TheSumOfItsParts.Parser.parse_all_steps([
      iex>   "Step C must be finished before step A can begin.",
      iex>   "Step C must be finished before step F can begin.",
      iex>   "Step A must be finished before step B can begin.",
      iex>   "Step A must be finished before step D can begin.",
      iex>   "Step B must be finished before step E can begin.",
      iex>   "Step D must be finished before step E can begin.",
      iex>   "Step F must be finished before step E can begin.",
      iex> ])
      %{
        "." => ["C"],
        "A" => ["B", "D"],
        "B" => ["E"],
        "C" => ["A", "F"],
        "D" => ["E"],
        "E" => [],
        "F" => ["E"],
      }
  """
  def parse_all_steps(instructions) do
    first_steps = parse_first_steps(instructions)

    instructions
    |> parse_all()
    |> Map.put(".", first_steps)
  end

  @doc """
  ## Examples

      iex> TheSumOfItsParts.Parser.parse_first_steps([
      iex>   "Step C must be finished before step A can begin.",
      iex>   "Step C must be finished before step F can begin.",
      iex>   "Step A must be finished before step B can begin.",
      iex>   "Step A must be finished before step D can begin.",
      iex>   "Step B must be finished before step E can begin.",
      iex>   "Step D must be finished before step E can begin.",
      iex>   "Step F must be finished before step E can begin.",
      iex> ])
      ["C"]
  """
  def parse_first_steps(instructions) do
    steps =
      instructions
      |> parse_all()
      |> Map.values()
      |> List.flatten()

    instructions
    |> parse_steps()
    |> Kernel.--(steps)
    |> Enum.sort()
  end

  @doc """
  ## Examples

      iex> TheSumOfItsParts.Parser.parse_all([
      iex>   "Step C must be finished before step A can begin.",
      iex>   "Step C must be finished before step F can begin.",
      iex>   "Step A must be finished before step D can begin.",
      iex>   "Step A must be finished before step B can begin.",
      iex>   "Step B must be finished before step E can begin.",
      iex>   "Step D must be finished before step E can begin.",
      iex>   "Step F must be finished before step E can begin.",
      iex> ])
      %{
        "A" => ["B", "D"],
        "B" => ["E"],
        "C" => ["A", "F"],
        "D" => ["E"],
        "E" => [],
        "F" => ["E"],
      }
  """
  def parse_all(instructions) do
    steps =
      instructions
      |> parse()
      |> Enum.group_by(fn [a, _b] -> a end, fn [_a, b] -> b end)
      |> Enum.map(fn {k, v} ->
        {k, Enum.sort(v)}
      end)
      |> Enum.into(%{})

    final_steps =
      instructions
      |> parse_steps()
      |> Kernel.--(Map.keys(steps))
      |> Enum.into(%{}, & {&1, []})

    Map.merge(steps, final_steps)
  end

  @doc """
  ## Examples

      iex> TheSumOfItsParts.Parser.parse_steps([
      iex>   "Step C must be finished before step A can begin.",
      iex>   "Step C must be finished before step F can begin.",
      iex>   "Step A must be finished before step B can begin.",
      iex>   "Step A must be finished before step D can begin.",
      iex>   "Step B must be finished before step E can begin.",
      iex>   "Step D must be finished before step E can begin.",
      iex>   "Step F must be finished before step E can begin.",
      iex> ])
      ["C", "A", "F", "B", "D", "E"]
  """
  def parse_steps(instructions) do
    instructions
    |> Enum.flat_map(&parse_line/1)
    |> Enum.uniq()
  end

  @doc """
  ## Examples

      iex> TheSumOfItsParts.Parser.parse([
      iex>   "Step C must be finished before step A can begin.",
      iex>   "Step C must be finished before step F can begin.",
      iex>   "Step A must be finished before step B can begin.",
      iex>   "Step A must be finished before step D can begin.",
      iex>   "Step B must be finished before step E can begin.",
      iex>   "Step D must be finished before step E can begin.",
      iex>   "Step F must be finished before step E can begin.",
      iex> ])
      [
        ["C", "A"],
        ["C", "F"],
        ["A", "B"],
        ["A", "D"],
        ["B", "E"],
        ["D", "E"],
        ["F", "E"],
      ]
  """
  def parse(instructions) do
    Enum.map(instructions, &parse_line/1)
  end

  @doc """
  ## Examples

      iex> TheSumOfItsParts.Parser.parse_line("Step C must be finished before step A can begin.")
      ["C", "A"]
  """
  def parse_line(instruction) do
    Regex.run(
      ~r/Step (\S) must be finished before step (\S)/,
      instruction,
      capture: :all_but_first
    )
  end
end
