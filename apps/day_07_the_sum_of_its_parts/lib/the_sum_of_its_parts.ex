defmodule TheSumOfItsParts do
  alias __MODULE__.Parser

  @doc """
  ## Examples

      iex> TheSumOfItsParts.order([
      iex>   "Step C must be finished before step A can begin.",
      iex>   "Step C must be finished before step F can begin.",
      iex>   "Step A must be finished before step B can begin.",
      iex>   "Step A must be finished before step D can begin.",
      iex>   "Step B must be finished before step E can begin.",
      iex>   "Step D must be finished before step E can begin.",
      iex>   "Step F must be finished before step E can begin.",
      iex> ])
      "CABDFE"
  """
  def order(instructions) do
    [first | first_steps] = Parser.parse_first_steps(instructions)

    instructions
    |> Parser.parse_all()
    |> sort_steps(first, first_steps, first)
  end

  defp sort_steps(steps, step, first_steps, output) do
    next_steps      = first_steps ++ Map.get(steps, step)
    remaining_steps = Map.delete(steps, step)

    blocked_steps =
      remaining_steps
      |> Map.values()
      |> List.flatten()
      |> Enum.uniq()

    case next_steps -- blocked_steps do
      [] -> output
      [next_step | more_steps] ->
        remaining_steps =
          remaining_steps
          |> Enum.map(fn {k, v} ->
            case next_step == k do
              true  -> {k, cleanse_steps(v ++ more_steps)}
              false -> {k, v}
            end
          end)
          |> Enum.into(%{})

        sort_steps(remaining_steps, next_step, [], output <> next_step)
    end
  end

  defp cleanse_steps(steps) do
    steps
    |> Enum.uniq()
    |> Enum.sort()
  end
end
