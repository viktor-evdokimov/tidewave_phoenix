# Check for available search tools
ripgrep_available = System.find_executable("rg") != nil

# Configure exclusions based on available tools
exclude = []
exclude = if !ripgrep_available, do: [:ripgrep | exclude], else: exclude

exclude =
  if !Tidewave.MCP.Tools.Process.can_trace?(), do: [:trace_process | exclude], else: exclude

ExUnit.start(exclude: exclude)
