defmodule Day03NoMatterHowYouSliceItTest do
  use ExUnit.Case, async: true

  doctest NoMatterHowYouSliceIt

  @moduletag :output

  doctest NoMatterHowYouSliceIt.Output
end
