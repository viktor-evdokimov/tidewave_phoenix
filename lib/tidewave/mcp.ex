defmodule Tidewave.MCP do
  @moduledoc false

  use Supervisor

  alias Tidewave.MCP

  def start_link(init_arg) do
    Supervisor.start_link(__MODULE__, init_arg, name: __MODULE__)
  end

  @impl true
  def init(_init_arg) do
    silence_logs()
    add_logger_backend()
    MCP.Server.init_tools()
    :persistent_term.put({__MODULE__, :cwd}, File.cwd!())

    children = [
      {Registry, name: MCP.Registry, keys: :unique},
      Tidewave.MCP.Logger
    ]

    Supervisor.init(children, strategy: :one_for_one)
  end

  @doc """
  Returns the working directory at startup.
  """
  def get_cwd, do: :persistent_term.get({__MODULE__, :cwd})

  if Mix.env() != :test do
    defp silence_logs do
      Logger.put_module_level(MCP.SSE, :none)
      Logger.put_module_level(MCP.Connection, :none)
      Logger.put_module_level(MCP.Server, :none)
    end
  else
    defp silence_logs, do: :ok
  end

  defp add_logger_backend() do
    :ok =
      :logger.add_handler(
        MCP.Logger,
        MCP.Logger,
        %{formatter: Logger.default_formatter(colors: [enabled: false])}
      )
  end
end
