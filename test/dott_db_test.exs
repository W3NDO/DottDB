defmodule DottDbTest do
  use ExUnit.Case
  doctest DottDb

  test "greets the world" do
    assert DottDb.hello() == :world
  end
end
