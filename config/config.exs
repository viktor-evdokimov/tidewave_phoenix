import Config

config :tidewave, :client_url, "https://tidewave.ai"

if config_env() == :test do
  config :tidewave,
    hex_req_opts: [
      plug: {Req.Test, Tidewave.MCP.Tools.Hex}
    ]
end
