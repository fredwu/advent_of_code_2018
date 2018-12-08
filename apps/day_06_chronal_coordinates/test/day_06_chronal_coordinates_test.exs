defmodule Day06ChronalCoordinatesTest do
  use ExUnit.Case, async: true

  doctest ChronalCoordinates
  doctest ChronalCoordinates.Coordinates
  doctest ChronalCoordinates.Distances
  doctest ChronalCoordinates.Owners

  @moduletag :output

  doctest ChronalCoordinates.Output
end
