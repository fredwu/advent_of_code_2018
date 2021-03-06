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
    instructions
    |> Parser.parse_all_steps()
    |> sort_steps(".")
  end

  defp sort_steps(steps, step, output \\ "") do
    next_steps      = steps |> Map.get(step)
    remaining_steps = steps |> Map.delete(step)
    blocked_steps   = remaining_steps |> Map.values() |> List.flatten()

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

        sort_steps(remaining_steps, next_step, output <> next_step)
    end
  end

  defp cleanse_steps(steps) do
    steps
    |> Enum.uniq()
    |> Enum.sort()
  end
end
