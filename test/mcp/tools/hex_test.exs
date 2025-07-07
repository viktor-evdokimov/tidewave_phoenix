defmodule Tidewave.MCP.Tools.HexTest do
  use ExUnit.Case, async: true

  alias Tidewave.MCP.Tools.Hex

  setup do
    Req.Test.set_req_test_from_context(%{})
    :ok
  end

  describe "search_package_docs/1" do
    test "successfully searches documentation" do
      Req.Test.stub(Tidewave.MCP.Tools.Hex, fn conn ->
        assert conn.query_params["filter_by"] =~ "plug"

        Req.Test.json(conn, %{
          "hits" => [
            %{
              "title" => "Phoenix.Controller",
              "doc" => "Controller functionality for Phoenix"
            }
          ]
        })
      end)

      assert {:ok, _} = Hex.search_package_docs(%{"q" => "controller"})
    end

    test "can provide list of packages" do
      Req.Test.stub(Tidewave.MCP.Tools.Hex, fn conn ->
        case conn.host do
          "hex.pm" ->
            Req.Test.json(conn, %{
              "releases" => [%{"version" => "1.7.29"}, %{"version" => "1.7.35"}]
            })

          "search.hexdocs.pm" ->
            assert conn.query_params["filter_by"] == "package:=[phoenix-1.7.35]"

            Req.Test.json(conn, %{
              "hits" => [
                %{
                  "title" => "Phoenix.Controller",
                  "doc" => "Controller functionality for Phoenix"
                }
              ]
            })
        end
      end)

      assert {:ok, _} =
               Hex.search_package_docs(%{
                 "q" => "controller",
                 "packages" => ["phoenix"]
               })
    end
  end
end
