defmodule Tidewave do
  @moduledoc false
  @behaviour Plug

  @impl true
  def init(opts), do: opts

  @impl true
  def call(%Plug.Conn{path_info: ["tidewave" | rest]} = conn, opts) do
    conn
    |> Plug.Conn.put_private(:tidewave_opts, opts)
    |> Plug.forward(rest, Tidewave.Router, [])
    |> Plug.Conn.halt()
  end

  def call(conn, _opts), do: conn
end
