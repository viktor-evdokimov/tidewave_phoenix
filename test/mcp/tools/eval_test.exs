defmodule Tidewave.MCP.Tools.EvalTest do
  use ExUnit.Case, async: true

  alias Tidewave.MCP.Tools.Eval

  describe "tools/0" do
    test "returns list of available tools" do
      tools = Eval.tools()

      assert is_list(tools)
      assert length(tools) == 2
      assert Enum.any?(tools, &(&1.name == "project_eval"))
      assert Enum.any?(tools, &(&1.name == "shell_eval"))

      # includes Elixir version in description
      assert Enum.find(tools, &(&1.name == "project_eval")).description =~ System.version()
    end
  end

  describe "project_eval/2" do
    test "evaluates simple Elixir expressions" do
      code = "1 + 1"

      assert {:ok, json, %{}} = Eval.project_eval(%{"code" => code}, Tidewave.init([]))
      assert Jason.decode!(json) == %{"result" => "2", "stdout" => ""}
    end

    test "evaluates complex Elixir expressions" do
      code = """
      defmodule Temp do
        def add(a, b), do: a + b
      end

      Temp.add(40, 2)
      """

      assert {:ok, json, %{}} = Eval.project_eval(%{"code" => code}, Tidewave.init([]))
      assert Jason.decode!(json) == %{"result" => "42", "stdout" => ""}
    end

    test "suports arguments" do
      assert {:ok, json, %{}} =
               Eval.project_eval(
                 %{"code" => "arguments", "arguments" => [1, "2"]},
                 Tidewave.init([])
               )

      assert Jason.decode!(json) == %{"result" => "[1, \"2\"]", "stdout" => ""}
    end

    test "returns strings as is" do
      file = File.read!(__ENV__.file)

      assert {:ok, json, %{}} =
               Eval.project_eval(
                 %{"code" => "hd(arguments)", "arguments" => [file]},
                 Tidewave.init([])
               )

      assert Jason.decode!(json) == %{"result" => file, "stdout" => ""}
    end

    test "returns formatted errors for exceptions" do
      code = "1 / 0"

      assert {:ok, json, %{}} = Eval.project_eval(%{"code" => code}, Tidewave.init([]))
      assert %{"result" => error, "stdout" => ""} = Jason.decode!(json)
      assert error =~ "ArithmeticError"
      assert error =~ "bad argument in arithmetic expression"
    end

    test "can use IEx helpers" do
      code = "h Tidewave"

      assert {:ok, json, %{}} = Eval.project_eval(%{"code" => code}, Tidewave.init([]))
      assert %{"result" => "", "stdout" => docs} = Jason.decode!(json)
      assert docs =~ "Tidewave"
    end

    test "catches exits" do
      assert {:error, "Failed to evaluate code. Process exited with reason: :brutal_kill"} =
               Eval.project_eval(
                 %{"code" => "Process.exit(self(), :brutal_kill)"},
                 Tidewave.init([])
               )
    end

    test "times out" do
      assert {:error, "Evaluation timed out after 50 milliseconds."} =
               Eval.project_eval(
                 %{"code" => "Process.sleep(10_000)", "timeout" => 50},
                 Tidewave.init([])
               )
    end

    test "returns IO up to exception" do
      assert {:ok, json, %{}} =
               Eval.project_eval(%{"code" => ~s[IO.puts("Hello!"); 1 / 0]}, Tidewave.init([]))

      assert %{"result" => error, "stdout" => stdout} = Jason.decode!(json)
      assert stdout =~ "Hello!"
      assert error =~ "ArithmeticError"
    end

    test "captures standard_error" do
      assert {:ok, json, %{}} =
               Eval.project_eval(
                 %{"code" => "hello"},
                 Tidewave.init([])
               )

      assert %{"result" => result, "stdout" => stdout} = Jason.decode!(json)
      assert result =~ "** (CompileError)"
      assert stdout =~ "undefined variable \"hello\""
    end
  end

  describe "shell_eval/1" do
    test "executes simple shell commands" do
      assert {:ok, "hello\n"} = Eval.shell_eval(%{"command" => "echo hello"})
    end

    test "executes commands with arguments" do
      assert {:ok, "hello world\n"} = Eval.shell_eval(%{"command" => "echo hello world"})
    end

    test "refuses to execute iex" do
      assert {:error, "Do not use shell_eval" <> _} = Eval.shell_eval(%{"command" => "iex -e 1"})
    end

    test "handles failed commands" do
      # Using a non-existent command
      command = "nonexistentcommand"

      assert {:error, message} = Eval.shell_eval(%{"command" => command})

      assert message =~ "Command failed with status"
    end

    test "is only listable if include_fs_tools is set" do
      {tools, _} = Tidewave.MCP.Server.tools_and_dispatch()
      assert %{listable: fun} = Enum.find(tools, fn %{name: name} -> name == "shell_eval" end)
      assert fun.(%{"include_fs_tools" => "true"})
      refute fun.(%{"other" => "params"})
    end
  end
end
