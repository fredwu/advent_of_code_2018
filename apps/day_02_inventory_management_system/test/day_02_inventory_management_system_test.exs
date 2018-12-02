defmodule Day02InventoryManagementSystemTest do
  use ExUnit.Case, async: true

  doctest InventoryManagementSystem
  doctest InventoryManagementSystem.Utils

  @moduletag :output

  doctest InventoryManagementSystem.Output
end
