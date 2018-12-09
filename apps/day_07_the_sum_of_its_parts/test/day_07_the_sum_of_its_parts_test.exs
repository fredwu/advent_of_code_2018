defmodule Day07TheSumOfItsPartsTest do
  use ExUnit.Case, async: true

  doctest TheSumOfItsParts
  doctest TheSumOfItsParts.Parser

  @moduletag :output

  doctest TheSumOfItsParts.Output
end
