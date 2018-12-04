defmodule Day04ReposeRecordTest do
  use ExUnit.Case, async: true

  doctest ReposeRecord
  doctest ReposeRecord.ShiftParser
  doctest ReposeRecord.Tokeniser

  @moduletag :output

  doctest ReposeRecord.Output
end
