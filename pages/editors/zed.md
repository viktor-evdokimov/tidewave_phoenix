# Zed

Zed currently only supports MCP through the IO protocol. So the first step is to install a [MCP Proxy](../guides/mcp_proxy.md).

At the time of writing, Zed agents/assistants are in beta. Therefore the instructions
below may be out of date. In any case, let's do this.

Zed agents/assistants are currently in beta and the steps below may not be
Once that's done, open up the Assistant tab and click on the `⋯` icon at the
top right (see image below):

![Zed AI panel](assets/vscode.png)

In the new pane, select "+ Add MCPs Directly", to open a new dialog. Fill in
the name of your choice and the command is the path to your MCP proxy followed
by space and the web server location such as:

    mcp-proxy http://localhost:4000/tidewave/mcp

And you are good to go! Now Zed will list all tools from Tidewave available.
