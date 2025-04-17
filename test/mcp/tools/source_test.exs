defmodule Tidewave.MCP.Tools.SourceTest do
  use ExUnit.Case, async: true

  alias Tidewave.MCP.Tools.Source

  describe "get_source_location/1" do
    test "returns source code error handling" do
      {:error, message} =
        Source.get_source_location(%{"module" => "NonExistentModule"})

      assert message =~ "Failed to get source location"
    end

    test "handles valid module" do
      result = Source.get_source_location(%{"module" => "Tidewave"})
      assert {:ok, text} = result
      assert text =~ "tidewave.ex"
    end

    test "does not work for Elixir modules" do
      {:error, message} = Source.get_source_location(%{"module" => "Enum"})
      assert message =~ "Cannot get source of core libraries"
    end
  end
end
