# MCP Proxy

Tidewave implements the SSE version of MCP protocol. Some tools may only support the IO
protocol but proxies are available in different languages. Pick whatever language is more
suitable to you.

## Elixir-based proxy

Requires Elixir installed on your machine. Then simply run:

```bash
$ mix escript.install hex mcp_proxy
```

The proxy will be installed at `~/.mix/escripts/mcp-proxy`.

It is recommended that you add `~/.mix/escripts` to your
[`$PATH`](https://en.wikipedia.org/wiki/PATH_(variable)).
If you don't, you will need to specify the full path to
the `mcp-proxy` executable when configuring your editor.

## Python-based proxy

Requires either `uv`, `npm`, or `pip` installed. See [the installation instructions on GitHub](https://github.com/sparfenyuk/mcp-proxy#installation).

It is recommended that you add the executable to your
[`$PATH`](https://en.wikipedia.org/wiki/PATH_(variable)).
If you don't, you will need to specify the full path to
the `mcp-proxy` executable when configuring your editor.