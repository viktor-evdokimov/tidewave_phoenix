# Claude

## Claude Desktop

In order to use Tidewave with Claude Desktop, you must first install a [`mcp-proxy`](../guides/mcp_proxy.md).

Then your Claude Desktop configuration looks like this:

```json
{
  "mcpServers": {
    "tidewave": {
      "command": "mcp-proxy",
      "args": ["http://localhost:$PORT/tidewave/mcp?include_fs_tools=true"]
    }
  }
}
```

Where `$PORT` is the port your web application is running on. Note we enabled filesystem
tools by default, as Claude Desktop does not support any filesystem operation out of the box.

Finally, the above assumes the `mcp-proxy` is available on your `$PATH`, otherwise you must
give the full path to the installed executable.

And you are good to go! Now Claude Desktop will list all tools from Tidewave available,
including filesystem ones.

## Claude Code

Adding Tidewave to [Claude Code](https://docs.anthropic.com/en/docs/agents-and-tools/claude-code/overview)
is straight-forward, just run:

```shell
$ claude mcp add --transport sse tidewave http://localhost:$PORT/tidewave/mcp
```

Where `$PORT` is the port your web application is running on. And you are good to go!
