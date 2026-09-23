## Security

> [!IMPORTANT]
> Any MCP client or server you enable can cause an AI agent to perform actions on your behalf. Only use trusted MCP clients and servers, carefully review which tools and data each agent can access, and apply least privilege (scoped tokens, minimal project/workspace access). For any high-impact or destructive action, require human confirmation.

- **Your credentials stay with you.** API keys are stored in your local config file and sent directly to Kaseya's MCP servers — they are never stored by this repository.
- **Nothing runs without your approval.** Every skill presents a plan and waits for explicit confirmation before executing. Any step that deletes or modifies data requires a separate confirmation on top of the overall plan.
- **Keep keys private.** Do not commit your `claude_desktop_config.json` to version control. Add it to `.gitignore` if you're working in a code project.
- **Rotate keys regularly.** If you see a disconnected server error on relaunch, your secret may have expired — regenerate it in the relevant platform and update your config.
