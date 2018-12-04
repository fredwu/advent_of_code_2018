defmodule ReposeRecord.Tokeniser do
  @doc """
  ## Examples

      iex> ReposeRecord.Tokeniser.tokenise("[1518-11-01 23:58] Guard #99 begins shift")
      %{
        "day"    => "1518-11-01",
        "hour"   => "23",
        "minute" => "58",
        "guard"  => "99",
        "action" => "begins_shift",
      }

      iex> ReposeRecord.Tokeniser.tokenise("[1518-11-02 00:40] falls asleep")
      %{
        "day"    => "1518-11-02",
        "hour"   => "00",
        "minute" => "40",
        "action" => "falls_asleep",
      }

      iex> ReposeRecord.Tokeniser.tokenise("[1518-11-02 00:50] wakes up")
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

      iex> ReposeRecord.Tokeniser.tokenise_timestamp("[1518-11-02 00:50] wakes up")
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

      iex> ReposeRecord.Tokeniser.tokenise_guard("[1518-11-01 23:58] Guard #99 begins shift")
      %{"guard" => "99"}

      iex> ReposeRecord.Tokeniser.tokenise_guard("[1518-11-02 00:40] falls asleep")
      %{}

      iex> ReposeRecord.Tokeniser.tokenise_guard("[1518-11-02 00:50] wakes up")
      %{}
  """
  def tokenise_guard(input) do
    input = cut_timestamp(input)

    Regex.named_captures(~r/Guard #(?<guard>\d+)/, input) || %{}
  end

  @doc """
  ## Examples

      iex> ReposeRecord.Tokeniser.tokenise_action("[1518-11-01 23:58] Guard #99 begins shift")
      %{"action" => "begins_shift"}

      iex> ReposeRecord.Tokeniser.tokenise_action("[1518-11-02 00:40] falls asleep")
      %{"action" => "falls_asleep"}

      iex> ReposeRecord.Tokeniser.tokenise_action("[1518-11-02 00:50] wakes up")
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

      iex> ReposeRecord.Tokeniser.cut_timestamp("[1518-11-01 23:58] Guard #99 begins shift")
      "Guard #99 begins shift"

      iex> ReposeRecord.Tokeniser.cut_timestamp("[1518-11-02 00:40] falls asleep")
      "falls asleep"

      iex> ReposeRecord.Tokeniser.cut_timestamp("[1518-11-02 00:50] wakes up")
      "wakes up"
  """
  def cut_timestamp(input), do: String.slice(input, 19..-1)
end
