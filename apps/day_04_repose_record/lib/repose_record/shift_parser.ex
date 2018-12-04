defmodule ReposeRecord.ShiftParser do
  alias ReposeRecord.Tokeniser

  @doc """
  ## Examples

      iex> ReposeRecord.ShiftParser.parse_shifts([
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

      iex> ReposeRecord.ShiftParser.chunk_shifts([
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

      iex> ReposeRecord.ShiftParser.guard_record?("[1518-11-01 23:58] Guard #99 begins shift")
      true

      iex> ReposeRecord.ShiftParser.guard_record?("[1518-11-02 00:40] falls asleep")
      false

      iex> ReposeRecord.ShiftParser.guard_record?("[1518-11-02 00:50] wakes up")
      false
  """
  def guard_record?(record), do: String.ends_with?(record, "shift")

  @doc """
  ## Examples

      iex> ReposeRecord.ShiftParser.parse_shift([
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

      iex> ReposeRecord.ShiftParser.parse_shift([
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

      iex> ReposeRecord.ShiftParser.parse_shift([
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
    |> Tokeniser.tokenise()
    |> Map.put("asleep", [])
    |> Map.put("sleep_duration", 0)
    |> Map.take(["guard", "day", "asleep", "sleep_duration"])
  end

  def parse_shift([guard_record | records]) do
    guard_tokens  = guard_record |> Tokeniser.tokenise()
    asleep_tokens = records |> hd() |> Tokeniser.tokenise()

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

      iex> ReposeRecord.ShiftParser.asleep_minutes([
      iex>   "[1518-11-01 00:05] falls asleep",
      iex>   "[1518-11-01 00:10] wakes up",
      iex> ])
      [5, 6, 7, 8, 9]

      iex> ReposeRecord.ShiftParser.asleep_minutes([
      iex>   "[1518-11-01 00:30] falls asleep",
      iex>   "[1518-11-01 00:32] wakes up",
      iex> ])
      [30, 31]
  """
  def asleep_minutes([asleep_record, awake_record]) do
    asleep_tokens = asleep_record |> Tokeniser.tokenise()
    awake_tokens  = awake_record  |> Tokeniser.tokenise()

    asleep_minute = asleep_tokens |> Map.get("minute") |> String.to_integer()
    awake_minute  = awake_tokens  |> Map.get("minute") |> String.to_integer()

    Enum.to_list(asleep_minute..(awake_minute - 1))
  end

  @doc """
  ## Examples

      iex> ReposeRecord.ShiftParser.sort([
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
