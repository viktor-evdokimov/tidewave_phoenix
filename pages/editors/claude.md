# Claude

## Claude Desktop

TODO.

In order to use Tidewave with Claude Desktop, you must first install a [`mcp_proxy`](../guides/mcp_proxy.md).

Then your Claude Desktop configuration looks like this:

```json
{
  "mcpServers": {
    "tidewave": {
      "command": "mcp_proxy",
      "env": {
        "SSE_URL": "http://localhost:$PORT/tidewave/mcp?include_fs_tools=true"
      }
    }
  }
}
```

Where `$PORT` is the port your web application is running on. Note we enabled filesystem tools by default, as Claude Desktop does not support any filesystem operation out of the box.

If you are using the Elixir version of the proxy, the command will be `"$HOME/.mix/escripts/mcp_proxy"`, where `$HOME` is the location of your home directory.

## Claude Code

TODO.