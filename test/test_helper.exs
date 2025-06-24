# Check for available search tools
ripgrep_available = System.find_executable("rg") != nil

# Configure exclusions based on available tools
exclude = []
exclude = if !ripgrep_available, do: [:ripgrep | exclude], else: exclude

ExUnit.start(exclude: exclude)
