defmodule ReposeRecord do
  require Integer

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
      |> parse_shifts()
      |> Enum.group_by(&Map.get(&1, "guard"), &{Map.get(&1, "sleep_duration"), Map.get(&1, "asleep")})
      |> Enum.map(fn {guard, sleeps} ->
        sleep_duration = Enum.reduce(sleeps, 0, fn {duration, _asleep}, acc -> duration + acc end)
        sleep_minutes  = Enum.flat_map(sleeps, fn {_duration, asleep} -> asleep end)

        {guard, sleep_duration, sleep_minutes}
      end)
      |> Enum.sort_by(fn {_guard, sleep_duration, _sleep_minutes} -> sleep_duration end, &>=/2)
      |> List.first()

    {lazy_minute, _count} =
      sleep_minutes
      |> Enum.reduce(%{}, & Map.update(&2, &1, 1, fn x -> x + 1 end))
      |> Enum.sort_by(fn {_k, v} -> v end, &>=/2)
      |> hd()

    {guard, lazy_minute}
  end

  @doc """
  ## Examples

      iex> ReposeRecord.parse_shifts([
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
      [
        %{
          "guard"          => "10",
          "day"            => "1518-11-01",
          "asleep"         => [5, 6, 7, 8, 9, 10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 24, 30, 31, 32, 33, 34, 35, 36, 37, 38, 39, 40, 41, 42, 43, 44, 45, 46, 47, 48, 49, 50, 51, 52, 53, 54],
          "sleep_duration" => 45,
        },
        %{
          "guard"          => "99",
          "day"            => "1518-11-02",
          "asleep"         => [40, 41, 42, 43, 44, 45, 46, 47, 48, 49],
          "sleep_duration" => 10,
        },
        %{
          "guard"          => "10",
          "day"            => "1518-11-03",
          "asleep"         => [24, 25, 26, 27, 28],
          "sleep_duration" => 5,
        },
        %{
          "guard"          => "99",
          "day"            => "1518-11-04",
          "asleep"         => [36, 37, 38, 39, 40, 41, 42, 43, 44, 45],
          "sleep_duration" => 10,
        },
        %{
          "guard"          => "99",
          "day"            => "1518-11-05",
          "asleep"         => [45, 46, 47, 48, 49, 50, 51, 52, 53, 54],
          "sleep_duration" => 10,
        },
      ]
  """
  def parse_shifts(records) do
    records
    |> sort()
    |> chunk_shifts()
    |> Enum.map(&parse_shift/1)
  end

  @doc """
  ## Examples

      iex> ReposeRecord.chunk_shifts([
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
      [
        [
          "[1518-11-01 00:00] Guard #10 begins shift",
          "[1518-11-01 00:05] falls asleep",
          "[1518-11-01 00:25] wakes up",
          "[1518-11-01 00:30] falls asleep",
          "[1518-11-01 00:55] wakes up",
        ],
        [
          "[1518-11-01 23:58] Guard #99 begins shift",
          "[1518-11-02 00:40] falls asleep",
          "[1518-11-02 00:50] wakes up",
        ],
        [
          "[1518-11-03 00:05] Guard #10 begins shift",
          "[1518-11-03 00:24] falls asleep",
          "[1518-11-03 00:29] wakes up",
        ],
        [
          "[1518-11-04 00:02] Guard #99 begins shift",
          "[1518-11-04 00:36] falls asleep",
          "[1518-11-04 00:46] wakes up",
        ],
        [
          "[1518-11-05 00:03] Guard #99 begins shift",
          "[1518-11-05 00:45] falls asleep",
          "[1518-11-05 00:55] wakes up",
        ],
      ]
  """
  def chunk_shifts(records) do
    Enum.chunk_while(records, [], fn
      record, [] -> {:cont, [record]}
      record, acc ->
        if guard_record?(record) do
          {:cont, acc, [record]}
        else
          {:cont, acc ++ [record]}
        end
    end, fn acc ->
      {:cont, acc, []}
    end)
  end

  @doc """
  ## Examples

      iex> ReposeRecord.parse_shift([
      iex>   "[1518-11-01 23:58] Guard #99 begins shift",
      iex>   "[1518-11-02 00:40] falls asleep",
      iex>   "[1518-11-02 00:50] wakes up",
      iex> ])
      %{
        "guard"          => "99",
        "day"            => "1518-11-02",
        "asleep"         => [40, 41, 42, 43, 44, 45, 46, 47, 48, 49],
        "sleep_duration" => 10,
      }

      iex> ReposeRecord.parse_shift([
      iex>   "[1518-11-01 00:00] Guard #10 begins shift",
      iex>   "[1518-11-01 00:05] falls asleep",
      iex>   "[1518-11-01 00:10] wakes up",
      iex>   "[1518-11-01 00:30] falls asleep",
      iex>   "[1518-11-01 00:32] wakes up",
      iex> ])
      %{
        "guard"          => "10",
        "day"            => "1518-11-01",
        "asleep"         => [5, 6, 7, 8, 9, 30, 31],
        "sleep_duration" => 7,
      }

      iex> ReposeRecord.parse_shift([
      iex>   "[1518-11-01 00:00] Guard #10 begins shift",
      iex> ])
      %{
        "guard"          => "10",
        "day"            => "1518-11-01",
        "asleep"         => [],
        "sleep_duration" => 0,
      }
  """
  def parse_shift([guard_record | []]) do
    guard_record
    |> tokenise()
    |> Map.put("asleep", [])
    |> Map.put("sleep_duration", 0)
    |> Map.take(["guard", "day", "asleep", "sleep_duration"])
  end

  def parse_shift([guard_record | records]) do
    guard_tokens  = guard_record |> tokenise()
    asleep_tokens = records |> hd() |> tokenise()

    asleep_minutes =
      records
      |> Enum.chunk_every(2)
      |> Enum.flat_map(&asleep_minutes/1)

    %{}
    |> Map.merge(guard_tokens)
    |> Map.merge(asleep_tokens)
    |> Map.put("asleep", asleep_minutes)
    |> Map.put("sleep_duration", Enum.count(asleep_minutes))
    |> Map.take(["guard", "day", "asleep", "sleep_duration"])
  end

  @doc """
  ## Examples

      iex> ReposeRecord.asleep_minutes([
      iex>   "[1518-11-01 00:05] falls asleep",
      iex>   "[1518-11-01 00:10] wakes up",
      iex> ])
      [5, 6, 7, 8, 9]

      iex> ReposeRecord.asleep_minutes([
      iex>   "[1518-11-01 00:30] falls asleep",
      iex>   "[1518-11-01 00:32] wakes up",
      iex> ])
      [30, 31]
  """
  def asleep_minutes([asleep_record, awake_record]) do
    asleep_tokens = asleep_record |> tokenise()
    awake_tokens  = awake_record  |> tokenise()

    asleep_minute = asleep_tokens |> Map.get("minute") |> String.to_integer()
    awake_minute  = awake_tokens  |> Map.get("minute") |> String.to_integer()

    Enum.to_list(asleep_minute..(awake_minute - 1))
  end

  @doc """
  ## Examples

      iex> ReposeRecord.tokenise("[1518-11-01 23:58] Guard #99 begins shift")
      %{
        "day"    => "1518-11-01",
        "hour"   => "23",
        "minute" => "58",
        "guard"  => "99",
        "action" => "begins_shift",
      }

      iex> ReposeRecord.tokenise("[1518-11-02 00:40] falls asleep")
      %{
        "day"    => "1518-11-02",
        "hour"   => "00",
        "minute" => "40",
        "action" => "falls_asleep",
      }

      iex> ReposeRecord.tokenise("[1518-11-02 00:50] wakes up")
      %{
        "day"    => "1518-11-02",
        "hour"   => "00",
        "minute" => "50",
        "action" => "wakes_up",
      }
  """
  def tokenise(input) do
    %{}
    |> Map.merge(tokenise_timestamp(input))
    |> Map.merge(tokenise_guard(input))
    |> Map.merge(tokenise_action(input))
  end

  @doc """
  ## Examples

      iex> ReposeRecord.tokenise_timestamp("[1518-11-02 00:50] wakes up")
      %{
        "day"    => "1518-11-02",
        "hour"   => "00",
        "minute" => "50",
      }
  """
  def tokenise_timestamp(input) do
    Regex.named_captures(~r/\[(?<day>\S+) (?<hour>\d{2}):(?<minute>\d{2})/, input)
  end

  @doc """
  ## Examples

      iex> ReposeRecord.tokenise_guard("[1518-11-01 23:58] Guard #99 begins shift")
      %{"guard" => "99"}

      iex> ReposeRecord.tokenise_guard("[1518-11-02 00:40] falls asleep")
      %{}

      iex> ReposeRecord.tokenise_guard("[1518-11-02 00:50] wakes up")
      %{}
  """
  def tokenise_guard(input) do
    input = cut_timestamp(input)

    Regex.named_captures(~r/Guard #(?<guard>\d+)/, input) || %{}
  end

  @doc """
  ## Examples

      iex> ReposeRecord.tokenise_action("[1518-11-01 23:58] Guard #99 begins shift")
      %{"action" => "begins_shift"}

      iex> ReposeRecord.tokenise_action("[1518-11-02 00:40] falls asleep")
      %{"action" => "falls_asleep"}

      iex> ReposeRecord.tokenise_action("[1518-11-02 00:50] wakes up")
      %{"action" => "wakes_up"}
  """
  def tokenise_action(input) do
    action =
      input
      |> cut_timestamp()
      |> String.split(" ")
      |> Enum.slice(-2..-1)
      |> Enum.join("_")

    %{"action" => action}
  end

  @doc """
  ## Examples

      iex> ReposeRecord.guard_record?("[1518-11-01 23:58] Guard #99 begins shift")
      true

      iex> ReposeRecord.guard_record?("[1518-11-02 00:40] falls asleep")
      false

      iex> ReposeRecord.guard_record?("[1518-11-02 00:50] wakes up")
      false
  """
  def guard_record?(record), do: String.ends_with?(record, "shift")

  @doc """
  ## Examples

      iex> ReposeRecord.cut_timestamp("[1518-11-01 23:58] Guard #99 begins shift")
      "Guard #99 begins shift"

      iex> ReposeRecord.cut_timestamp("[1518-11-02 00:40] falls asleep")
      "falls asleep"

      iex> ReposeRecord.cut_timestamp("[1518-11-02 00:50] wakes up")
      "wakes up"
  """
  def cut_timestamp(input), do: String.slice(input, 19..-1)

  @doc """
  ## Examples

      iex> ReposeRecord.sort([
      iex>   "[1518-11-01 00:05] falls asleep",
      iex>   "[1518-11-05 00:55] wakes up",
      iex>   "[1518-11-01 00:00] Guard #10 begins shift",
      iex>   "[1518-11-01 00:30] falls asleep",
      iex>   "[1518-11-01 00:25] wakes up",
      iex>   "[1518-11-03 00:24] falls asleep",
      iex>   "[1518-11-04 00:46] wakes up",
      iex>   "[1518-11-01 00:55] wakes up",
      iex>   "[1518-11-04 00:02] Guard #99 begins shift",
      iex>   "[1518-11-03 00:29] wakes up",
      iex>   "[1518-11-02 00:50] wakes up",
      iex>   "[1518-11-02 00:40] falls asleep",
      iex>   "[1518-11-03 00:05] Guard #10 begins shift",
      iex>   "[1518-11-04 00:36] falls asleep",
      iex>   "[1518-11-05 00:03] Guard #99 begins shift",
      iex>   "[1518-11-01 23:58] Guard #99 begins shift",
      iex>   "[1518-11-05 00:45] falls asleep",
      iex> ])
      [
        "[1518-11-01 00:00] Guard #10 begins shift",
        "[1518-11-01 00:05] falls asleep",
        "[1518-11-01 00:25] wakes up",
        "[1518-11-01 00:30] falls asleep",
        "[1518-11-01 00:55] wakes up",
        "[1518-11-01 23:58] Guard #99 begins shift",
        "[1518-11-02 00:40] falls asleep",
        "[1518-11-02 00:50] wakes up",
        "[1518-11-03 00:05] Guard #10 begins shift",
        "[1518-11-03 00:24] falls asleep",
        "[1518-11-03 00:29] wakes up",
        "[1518-11-04 00:02] Guard #99 begins shift",
        "[1518-11-04 00:36] falls asleep",
        "[1518-11-04 00:46] wakes up",
        "[1518-11-05 00:03] Guard #99 begins shift",
        "[1518-11-05 00:45] falls asleep",
        "[1518-11-05 00:55] wakes up",
      ]
  """
  def sort(records), do: Enum.sort(records)
end
