defmodule Day03NoMatterHowYouSliceItTest do
  use ExUnit.Case, async: true

  doctest NoMatterHowYouSliceIt

  @moduletag :output
  @moduletag timeout: 300_000

  doctest NoMatterHowYouSliceIt.Output
end
