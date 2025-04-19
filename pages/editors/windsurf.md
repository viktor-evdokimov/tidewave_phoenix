# Windsurf

You can use Tidewave with Windsurf. First, you must first install a [`mcp_proxy`](../guides/mcp_proxy.md).

Once you are done, open up your "Windsurf Settings", find the "Cascade" section,
click "Add Server" and then "Add custom server". A file will open up and you can
manually add Tidewave, as follows:

```json
{
  "mcpServers": {
    "tidewave": {
      "command": "mcp-proxy",
      "args": ["http://localhost:$PORT/tidewave/mcp"]
    }
  }
}
```

Where `$PORT` is the port your web application is running on.

Note the above assumes the `mcp-proxy` is available on your `$PATH`,
otherwise you must give the full path to the installed executable.

And you are good to go! Now Windsurf will list all tools from Tidewave
available.