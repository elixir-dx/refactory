defmodule RefineryTest do
  use ExUnit.Case
  doctest Refinery

  test "greets the world" do
    assert Refinery.hello() == :world
  end
end
