# VS Code

You can use Tidewave with Visual Studio Code through the [GitHub Copilot extension](https://marketplace.visualstudio.com/items?itemName=GitHub.copilot).

At the time of writing, MCP support is only available in "Agent" mode. Open up your AI
assistant and then click on the red arrow in your editor (shown below) to enable "Agent"
mode and then the Wrench icon (pointed by the green arrow) to configure it.

![VSCode AI panel](assets/vscode.png)

And then at the center top:

1. Choose "+ Add MCP Server..."

2. Choose "HTTP (Server sent events)..."

3. Add the URL your web application is running on with `/tidewave/mcp` at the end, such as `localhost:4000/tidewave/mcp`

4. Add a name of your choice

And you are ready to go! Now the Copilot extension will list all tools available from
Tidewave.
