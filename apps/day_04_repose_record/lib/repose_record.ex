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

      iex> ReposeRecord.lazy_minute_number([
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
      4455
  """
  def lazy_minute_number(records) do
    {guard, minute} = lazy_minute_guard(records)

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
      |> sleep_accumulated_shifts()
      |> Enum.sort_by(fn {_guard, sleep_duration, _sleep_minutes} -> sleep_duration end, &>=/2)
      |> List.first()

    {lazy_minute, _count} = sleepiest_minute(sleep_minutes)

    {guard, lazy_minute}
  end

  @doc """
  ## Examples

      iex> ReposeRecord.lazy_minute_guard([
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
      {"99", 45}
  """
  def lazy_minute_guard(records) do
    {guard, {minute, _count}} =
      records
      |> sleep_accumulated_shifts()
      |> Enum.map(fn {guard, _duration, asleep} -> {guard, sleepiest_minute(asleep)} end)
      |> Enum.sort_by(fn {_guard, {_minute, count}} -> count end, &>=/2)
      |> hd()

    {guard, minute}
  end

  @doc """
  ## Examples

      iex> ReposeRecord.sleepiest_minute([1, 1, 2, 2, 2, 2, 3, 4, 5, 5])
      {2, 4}

      iex> ReposeRecord.sleepiest_minute([])
      {0, 0}
  """
  def sleepiest_minute([]), do: {0, 0}
  def sleepiest_minute(minutes) do
    minutes
    |> Enum.reduce(%{}, & Map.update(&2, &1, 1, fn x -> x + 1 end))
    |> Enum.sort_by(fn {_k, v} -> v end, &>=/2)
    |> hd()
  end

  defp sleep_accumulated_shifts(records) do
    records
    |> ShiftParser.parse_shifts()
    |> Enum.group_by(&Map.get(&1, "guard"), &{Map.get(&1, "sleep_duration"), Map.get(&1, "asleep")})
    |> Enum.map(&sleep_accumulator/1)
  end

  defp sleep_accumulator({guard, sleeps}) do
    sleep_duration = Enum.reduce(sleeps, 0, fn {duration, _asleep}, acc -> duration + acc end)
    sleep_minutes  = Enum.flat_map(sleeps, fn {_duration, asleep} -> asleep end)

    {guard, sleep_duration, sleep_minutes}
  end
end
