defmodule ReposeRecord do
  alias __MODULE__.ShiftParser

  @doc """
  ## Examples

      iex> ReposeRecord.lazy_number([
      iex>   "[1518-11-01 00:00] Guard #10 begins shift",
      iex>   "[1518-11-01 00:05] falls asleep",
      iex>   "[1518-11-01 00:25] wakes up",
      iex>   "[1518-11-01 00:30] falls asleep",
      iex>   "[1518-11-01 00:55] wakes up",
      iex>   "[1518-11-01 23:58] Guard #99 begins shift",
      iex>   "[1518-11-02 00:40] falls asleep",
      iex>   "[1518-11-02 00:50] wakes up",
      iex>   "[1518-11-03 00:05] Guard #10 begins shift",
      iex>   "[1518-11-03 00:24] falls asleep",
      iex>   "[1518-11-03 00:29] wakes up",
      iex>   "[1518-11-04 00:02] Guard #99 begins shift",
      iex>   "[1518-11-04 00:36] falls asleep",
      iex>   "[1518-11-04 00:46] wakes up",
      iex>   "[1518-11-05 00:03] Guard #99 begins shift",
      iex>   "[1518-11-05 00:45] falls asleep",
      iex>   "[1518-11-05 00:55] wakes up",
      iex> ])
      240
  """
  def lazy_number(records) do
    {guard, minute} = lazy_guard(records)

    String.to_integer(guard) * minute
  end

  @doc """
  ## Examples

      iex> ReposeRecord.lazy_guard([
      iex>   "[1518-11-01 00:00] Guard #10 begins shift",
      iex>   "[1518-11-01 00:05] falls asleep",
      iex>   "[1518-11-01 00:25] wakes up",
      iex>   "[1518-11-01 00:30] falls asleep",
      iex>   "[1518-11-01 00:55] wakes up",
      iex>   "[1518-11-01 23:58] Guard #99 begins shift",
      iex>   "[1518-11-02 00:40] falls asleep",
      iex>   "[1518-11-02 00:50] wakes up",
      iex>   "[1518-11-03 00:05] Guard #10 begins shift",
      iex>   "[1518-11-03 00:24] falls asleep",
      iex>   "[1518-11-03 00:29] wakes up",
      iex>   "[1518-11-04 00:02] Guard #99 begins shift",
      iex>   "[1518-11-04 00:36] falls asleep",
      iex>   "[1518-11-04 00:46] wakes up",
      iex>   "[1518-11-05 00:03] Guard #99 begins shift",
      iex>   "[1518-11-05 00:45] falls asleep",
      iex>   "[1518-11-05 00:55] wakes up",
      iex> ])
      {"10", 24}
  """
  def lazy_guard(records) do
    {guard, _sleep_duration, sleep_minutes} =
      records
      |> ShiftParser.parse_shifts()
      |> Enum.group_by(&Map.get(&1, "guard"), &{Map.get(&1, "sleep_duration"), Map.get(&1, "asleep")})
      |> Enum.map(&sleep_accumulator/1)
      |> Enum.sort_by(fn {_guard, sleep_duration, _sleep_minutes} -> sleep_duration end, &>=/2)
      |> List.first()

    {lazy_minute, _count} =
      sleep_minutes
      |> Enum.reduce(%{}, & Map.update(&2, &1, 1, fn x -> x + 1 end))
      |> Enum.sort_by(fn {_k, v} -> v end, &>=/2)
      |> hd()

    {guard, lazy_minute}
  end

  defp sleep_accumulator({guard, sleeps}) do
    sleep_duration = Enum.reduce(sleeps, 0, fn {duration, _asleep}, acc -> duration + acc end)
    sleep_minutes  = Enum.flat_map(sleeps, fn {_duration, asleep} -> asleep end)

    {guard, sleep_duration, sleep_minutes}
  end
end
