| Symptom | Likely Cause | Fix |
|----------|----------|----------|
| Servers not appearing after restart | Node.js not installed (Windows) | Install a compatible runtime such as Node.js, restart your machine, then restart Claude |
| Connection errors on all three servers | JSON syntax error in config | Re-copy the config block from this document, repaste it into the file, and re-enter your credentials in the highlighted placeholders |
| One server connects, others don't | Wrong credential pasted for that server | Re-check that server's API key/secret against what was generated in the platform |
| Changes not reflected after saving | Claude not fully quit | Use Task Manager (Windows) or Cmd+Q (Mac) to force-quit, then reopen Claude |
| Notified MCP server(s) are disconnected when relaunching Claude and they were already successfully connected | Secret expired | Generate new secret keys for applicable MCP server and update config files accordingly |
| Servers not appearing after editing the configuration file | Configuration file syntax disrupted during editing | Paste the original code block at the start of the file, or run the file through Claude to check for syntax errors |