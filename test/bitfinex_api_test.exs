defmodule BitfinexApiTest do
  use ExUnit.Case
  doctest BitfinexApi

  test "greets the world" do
    assert BitfinexApi.hello() == :world
  end
end
