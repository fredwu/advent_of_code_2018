defmodule Day04ReposeRecordTest do
  use ExUnit.Case, async: true

  doctest ReposeRecord

  @moduletag :output

  doctest ReposeRecord.Output
end
