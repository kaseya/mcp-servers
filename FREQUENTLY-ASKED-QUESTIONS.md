# Frequently asked questions

Find answers to common questions about the Kaseya MCP servers for Autotask, Datto RMM, and IT Glue. Click a link to go to the FAQs you need:

- [General FAQs](#general-faqs)
- [Autotask FAQs](#autotask-faqs)
- [Datto RMM FAQs](#datto-rmm-faqs)
- [IT Glue FAQs](#it-glue-faqs)

Roadmap statements below describe current plans. They are not commitments and may change.

For setup steps, see the [README](README.md).

---

## General FAQs

Find answers to questions that apply to all Kaseya MCP servers, such as availability, roadmap, identity and security, setup, capabilities, and support.

| Category | Question | Answer |
| --- | --- | --- |
| Roadmap, identity, and security | **Will this expand to a unified data layer rather than individual platform connectors? Is there a timeline for a single Kaseya MCP so we don't repeat the setup for every product?** | Unified APIs are planned for FY27. Unified Kaseya Claude connector is also in the roadmap. |
| Roadmap, identity, and security | **Which Kaseya products have MCP servers, and will others (MDR, EDR, RapidFire Tools, Inky, Kaseya SIEM, Smart Insights, etc.) be added?** | Early access covers Autotask, Datto RMM and IT Glue MCP servers. We do not have a timeline for other products at this time. |
| Roadmap, identity, and security | **When will the MCP servers be generally available? Is this open to all customers?** | The Kaseya MCP servers for Autotask, Datto RMM, and IT Glue are currently in an early access release, which is available to all customers. |
| Roadmap, identity, and security | **Is an MCP gateway planned so I do not have to give every technician an API key or share one key across my team? How will this scale beyond a single administrator?** | Yes, this work is in progress. Kaseya is unifying user identity with API identity and putting all APIs behind OAuth 2.1, and then will release MCP connectors that do not require you to use API keys. The target is FY27. OAuth 2.1 sign in is available to all IT Glue customers: each technician signs in with their own IT Glue account, so no API key is needed. For Autotask and Datto RMM, please generate a separate API key for each person or role. For example, create one read-only API user for technicians and one read/write API user for power users. |
| Roadmap, identity, and security | **Can I limit what each individual user can do through the MCP, instead of everything the API user can do?** | The MCP server access is tied to the API key. For IT Glue, when you sign in with your IT Glue account, Claude follows that user's role and organization restrictions instead. |
| Roadmap, identity, and security | **What is the limit for calls through the MCP servers?** | The limit is the same as your account's API throttling limit. |
| Setup and connectivity | **Can I connect to the MCP servers using a different platform than Claude (CoPilot, ChatGPT)?** | You are welcome to use any AI tool to connect to our MCP servers, but we are certifying it for Claude Desktop and Claude Code. Kaseya cannot assist with any troubleshooting relating to connections with different AI tools. |
| Setup and connectivity | **What do I need in place before I can connect?** | Claude Desktop installed, access to the GitHub repo, and your API credentials generated for each product. The repo README is the source of truth covering these steps - begin with [Getting Started](README.md#getting-started), which covers the pre-reqs. |
| Setup and connectivity | **Claude shows a red warning when I install the extension. Is this running anything on my computer?** | No. The Kaseya MCP server is remote. The extension only connects Claude to it and does not do anything on your desktop or file system. Anthropic shows this warning for every extension. |
| Setup and connectivity | **I get an error dragging the .mcpb file into Claude.** | Re-download it; the file likely didn't download fully. |
| Setup and connectivity | **Which Claude plan is enough for this? (Hit the free usage limit.)** | It depends on your usage and Anthropic agreement. |
| Setup and connectivity | **How do I know whether the connection worked? I saved my credentials and nothing happened.** | There is no success message. Toggle the extension from Disabled to Enabled: if it turns blue/Enabled it connected; if not, an error appears (post it in the chat, Teams or Discord). Open Configure to confirm: you should see the list of Autotask read and write tools. If you fix a setting (for example adding https:// to the URL), toggle it off and on again. Once enabled, open a chat and ask in natural language; Claude chooses the tools itself. |
| Setup and connectivity | **Is there documentation for setting up skills? Which files do I download, and where do I upload them?** | Yes. Follow [Step 2](README.md#step-2-connect-to-mcp-servers-and-install-skills-in-claude-desktop) in the README. For each product, download the MCPB file and the plugin ZIP file from the product folder. Add the MCPB file under **Extensions**, and then upload the plugin ZIP file under **Plugins**. The plugin ZIP file contains the skills for that product. Common mix-up: Claude has a **Skills** section, but you upload Kaseya skills as plugins. |
| Setup and connectivity | **Where do I generate the API keys for each product?** | See [Generating API keys](GENERATING-API-KEYS.md), which includes detailed steps and screenshots for each product, and the Autotask zone and endpoint lookup. For IT Glue, you can sign in with your IT Glue account instead of using an API key. |
| Capabilities and limitations | **Can the MCP update IT Glue documentation from ticket information once the products are linked?** | Yes. With the Autotask and IT Glue MCP servers connected, `itglue-update-docs-from-ticket` reads a ticket and proposes edits to existing documents, and `itglue-create-docs-from-ticket` creates a new document from it. Both wait for your approval before writing. Other cross-product workflows are the long-term goal. |
| Capabilities and limitations | **What skills does Kaseya provide, and how do they work?** | See the [Skills](README.md#skills) section of the README for the full list, and [Kaseya tools and skills](README.md#kaseya-tools--skills) to learn how skills work. For details about each skill, see the skills documentation in each product folder: [Autotask](AUTOTASK/), [Datto RMM](RMM/), and [IT Glue](ITGLUE/). |
| Capabilities and limitations | **Can I control which actions Claude can take, such as read versus write or delete?** | Yes. After you install the extension, open **Configure**. Separate dropdowns control read tools and write/delete tools. While you test, select **Needs Approval** for both. Once you trust the read tools, select **Always Allow** for read tools, and keep write/delete tools on **Needs Approval**. The same settings apply to Kaseya skills, so a skill that writes still asks for permission first. Try read queries before you write to production. |
| Capabilities and limitations | **Are there example prompts to get started?** | Yes. See the skills documentation in each product folder for example prompts that invoke each skill: [Autotask](AUTOTASK/), [Datto RMM](RMM/), and [IT Glue](ITGLUE/). |
| Capabilities and limitations | **Can I build my own skills or routines on top of the MCP tools?** | Yes. You are welcome to build your own skills from the tools. Tip: add your existing knowledge base (KB) articles to Claude and ask it to create a skill from them. Some customers plan to schedule routines (for example, in Claude Cowork) once write access is turned on. We would love to have you share your skills in Discord. Community show-and-tell sessions are planned; see Discord for the schedule. |
| Capabilities and limitations | **Why does my output, such as a dashboard or table, look different from what others show?** | In Claude, your account instructions, as well as your past usage history, leads to the same prompt on the same data showing different output. |
| Other AI platforms, strategy, and community | **Can I use the MCP servers with Copilot Studio, ChatGPT, or my own custom agent? Can I load the `.mcpb` files as-is?** | Kaseya supports Claude Desktop and Claude Code. Copilot Studio can connect to the MCP servers, and Kaseya plans official support in FY27. Until then, Kaseya cannot provide troubleshooting or instructions for other AI tools because the materials are written for Claude, but you are welcome to try the repo and share your results with the community on Discord. The `.mcpb` files work only with Claude. For Copilot Studio, follow Microsoft's documentation to add the endpoint. For a custom agent, write code that calls the endpoint with your credentials. Kaseya has no guidance for ChatGPT at this time. |
| Other AI platforms, strategy, and community | **Why does Kaseya offer an MCP instead of in-app native tools, API-only access, or letting customers build their own?** | Customers already make billions of API calls each month, and many asked for official MCP servers to use with their agents and Claude. |
| Other AI platforms, strategy, and community | **What is the roadmap beyond the early access, and will Kaseya share it?** | Yes, Kaseya will share the roadmap. Focus areas include OAuth 2.1 support for APIs (IT Glue supports it now), with Anthropic connectors to follow, and Kaseya Insights and actions inside the product. |
| Other AI platforms, strategy, and community | **Do MCP calls count against my hourly API call limit, and is there a charge?** | The MCP servers are free, and calls through them are subject to your account's API throttling limit. In the future, Kaseya may begin charging for API calls above a certain high threshold. |
| Other AI platforms, strategy, and community | **How should I share skills and prompts with the group?** | Share in the MCP servers channel in Discord! Kaseya will host show-and-tell community sessions; see Discord for the schedule. |
| Program, support, and feedback | **When are office hours, and what are they for?** | Office hours Mondays and Wednesdays from 11:00 AM to 12:00 PM Eastern for the duration of the alpha. Drop in and out any time for live demos, troubleshooting, access to product managers to discuss use cases, and time with other customers. Special sessions focus on sharing skills and prompts and on customers trying tools other than Claude. If office hours are not on your calendar, email sarah.tappan@kaseya.com. |
| Program, support, and feedback | **How do I contact the team, give feedback, or request features?** | Use the Teams channel **MCP Servers pre-alpha - General** or Discord. Discord will be the main community after the program. You can also [book a 1:1 feedback session](https://calendly.com/billing-kaseya-one/mcp-server-pre-alpha-program-feedback-session). Expect a weekly survey and a post-kickoff survey. Feature requests are welcome in any of these channels. |
| Program, support, and feedback | **Will I get a recording of the kickoff session? I missed some of the install steps.** | Yes, Kaseya will share recordings with the group. You can also follow the steps in [Getting Started](README.md#getting-started) and drop into office hours for help. |
| Kaseya Insights | **What is Kaseya Insights, and can I join?** | Kaseya Insights is a new platform capability with its own alpha program, built for MSP owners and administrators. It answers business and operational questions through a conversational interface inside KaseyaOne. It currently answers 100 to 200+ questions across Autotask and Datto RMM, with more products coming. The Insights alpha starts in mid-November. Everyone in North America can join. |

---

## Autotask FAQs

Find answers to questions about connecting to and using the Autotask MCP server, including endpoints, multiple instances, and Autotask capabilities.

| Category | Question | Answer |
| --- | --- | --- |
| Setup and connectivity | **Which MCP endpoint do I use (e.g. mcp2 vs mcp3)? If my Autotask URL is ww14, should I use https://mcp14.autotask.net/mcp?** | It depends on your Autotask zone. Take your Autotask API host, replace "webservices" with "mcp" and add "/mcp" (e.g. webservices3 → https://mcp3.autotask.net/mcp). The zone lookup can be found [here](GENERATING-API-KEYS.md#autotask). Correct format must include https:// at the front. |
| Setup and connectivity | **Why is my Autotask MCP server URL not accepted, or why does the connection fail?** | You must include `https://` at the front of the URL, and the URL must end with `/mcp`. For example, `https://mcp3.autotask.net/mcp`. |
| Setup and connectivity | **Can I connect more than one instance of Autotask to the MCP servers in Claude?** | Yes, you can connect multiple instances of Autotask to MCP servers. Follow these steps:<br>1. Rename `autotask-#-##-##.mcpb` to `.zip`<br>2. Extract it.<br>3. Edit `manifest.json`.<br>4. Change `name` and `display_name` so they identify the tenant, for example `autotask-Company B` / `Autotask - Company B`.<br>5. Zip it again.<br>6. Rename `.zip` back to `.mcpb`.<br>7. Add the new MCPB to Claude as another extension.<br><br>**Note:** When prompting, explicitly identify the MCP/endpoint you want Claude to use. Otherwise Claude may choose the connector based on previous context. |
| Capabilities and limitations | **Can the MCP do a global notes search?** | No. Global Notes Search, as it exists in the Autotask user interface (UI), is not an API endpoint, so it is not in the initial MCP. You can retrieve notes tied to a specific ticket, company, or device by using the autotask-briefing skill. Currently, you can query only `ticketNotes`. |
| Capabilities and limitations | **Can the MCP audit my workflow rules?** | No. Workflow rules are not an entity in the API, so the MCP cannot audit them. Autotask has a built-in workflow audit function in the UI, on the workflow page, that finds redundant and unused workflows. |
| Capabilities and limitations | **Can a workflow change the company on a ticket?** | No. Workflow rules cannot change the company on a ticket, by design. You can change the company ID through the API, and so through the MCP, as long as the ticket has no billing dependencies, such as time entries, expenses, or ticket charges (especially posted ones). The UI has the same restriction. For email processing, put `//` followed by the exact company name in the ticket body so that Autotask matches the account. |
| Capabilities and limitations | **Can I create a dashboard to share with a client?** | A dashboard is a Claude artifact, so you can share the output, such as a PDF download or HTML. |
| Capabilities and limitations | **Can the MCP export data, such as issues and sub-issues, to Excel?** | Yes. Prompt Claude to create the insights you want in an Excel file, and then download it. For example, Claude can create a summary of issues and sub-issues. |

---

## Datto RMM FAQs

Find answers to questions about connecting to and using the Datto RMM MCP server, including installation, regions, and permissions.

| Category | Question | Answer |
| --- | --- | --- |
| Setup and connectivity | **Why is the Datto RMM MCP server installed in the Organization settings, not at the user level like the Autotask MCP server?** | For Datto RMM, the client is a stdio bridge, which runs locally on each user's machine. Each user's Claude Desktop runs its own copy, so you cannot install it once at the organization level. An admin can still deploy the extension to everyone through Claude Desktop's managed extensions. Each user then enters their own API credentials. |
| Setup and connectivity | **Is the Datto RMM MCP server available in my region?** | Yes. All Datto RMM MCP servers are deployed, and all regions should be supported. |
| Setup and connectivity | **Datto RMM connects, but my queries fail with a 403 Forbidden error, for example when I ask how many sites I have. What do I do?** | A 403 error means Datto RMM accepted your API key, but the API user doesn't have sufficient permissions for this request. To resolve this, go to Setup > Users, locate the user that owns the API key, and assign an API Security Level with the appropriate permissions. The Administrator level provides full access, so we recommend using it only when necessary. For more details on API permissions and setup, please see the Datto RMM API v2 documentation: (https://rmm.datto.com/help/en/Content/2SETUP/APIv2.htm). |

---

## IT Glue FAQs

Find answers to questions about connecting to and using the IT Glue MCP server, including regions, OAuth 2.1 sign in, and API keys.

| Category | Question | Answer |
| --- | --- | --- |
| Setup and connectivity | **Is the IT Glue MCP server available in my region, and what do I enter for the region?** | Yes. The IT Glue MCP servers are available in all regions: Australia, Europe, and North America. The IT Glue configuration panel states at the top what to enter for each region. OAuth 2.1 sign in is available to all IT Glue customers in all regions. For the OAuth 2.1 endpoint for your region, see [Option 1](README.md#option-1-oauth-21-sign-in-it-glue-only---preferred) in Step 2 of the README. |
| Setup and connectivity | **IT Glue shows the error "IT Glue rejected the credential, or MCP is not enabled for this account," even after I regenerate my API key. What do I do?** | During early access, the IT Glue product team turns on MCP for each account with a feature flag. If you see this error, your account most likely does not have MCP turned on yet, rather than having a bad key. If the error continues, post in Teams or Discord, or join an office hour, so the IT Glue team can check your account. |
| Setup and connectivity | **I signed in to IT Glue, but Claude shows an "access denied" error. What do I do?** | MCP sign in needs to be turned on for your IT Glue account. If you see this error after signing in, your account most likely does not have it turned on yet. The same error appears if you sign in from outside your account's IP allowlist. Contact IT Glue support so they can check your account. In the meantime, you can connect with an API key instead. |
