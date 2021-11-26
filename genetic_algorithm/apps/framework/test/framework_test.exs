defmodule FrameworkTest do
  use ExUnit.Case
  doctest Framework

  test "greets the world" do
    assert Framework.hello() == :world
  end
end
