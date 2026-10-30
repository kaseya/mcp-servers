# Kaseya Readme - MCP servers and skills

**Find the official Kaseya Model Context Protocol (MCP) servers, tools, and skills for MSP and IT operations builders.**

## Overview

This repo provides MCP servers that connect Claude Desktop to Kaseya products. It also provides skills and other automation libraries you can try and contribute to.

Kaseya MCPs serve as a connector between AI tools and Kaseya products, such as Datto RMM, Autotask PSA, and IT Glue, facilitating access to supported functionality through their APIs. MCPs include Kaseya-built skills and help automate common MSP workflows, so you don't have to build and maintain everything yourself.

This community proves patterns, builds guardrails, and makes collective expertise available to every member who needs it.

> [!NOTE]
> This release is in alpha. MCP server availability and skill scope may change as testing continues.

---

### What we share

This repo includes:

- **MCP servers** - first-party connectors that give AI tools access to Kaseya product data and actions for Datto RMM, Autotask PSA, and IT Glue
- **Skills** - pre-built, reusable skills for Claude that automate common MSP workflows
- **Setup instructions** - steps to connect MCP servers and install skills in Claude

---

### Who this is for

This repo is for:

- MSP technicians, engineers, automation engineers, and technical leads
- IT operations builders at internal IT departments
- Tool vendors building integrations

---

### Community channels & support

| Channel         | Details                                                 |
| --------------- | ------------------------------------------------------- |
| Discord and Microsoft Teams   | You received a discord link and Teams invite a few days prior to kickoff. Reach out to sarah.tappan@kaseya.com with any issues. |
| Office Hours    | Daily. See Discord for the schedule.                    |
| Community Calls | Bi-weekly. See Discord for the schedule.                |

---

## Table of Contents

1. [Getting Started](#getting-started)
2. [Supported Clients](#supported-clients)
3. [Supported Products and Tools](#supported-products-and-tools)
4. [Kaseya Tools & Skills](#kaseya-tools--skills)
5. [RMM Resources](RMM/)
6. [Autotask Resources](AUTOTASK/)
7. [IT Glue Resources](ITGLUE/)
8. [Disclaimer](Governance/DISCLAIMERS.md#disclaimers-and-claim-waivers)
9. [Security](Governance/SECURITY.md)
10. [Code of Conduct](Governance/CODE_OF_CONDUCT.md)
11. [Governance Policy](Governance/GOVERNANCE.md)
12. [Customer FAQs](#faqs)

---

## Getting Started

To get started, complete the following steps:

1. Browse the repo for tools, skills, and MCP servers relevant to your stack.
2. Try something - break it, learn from it, and share what you found.
3. Review the prerequisites, and then follow the setup steps to connect your MCP servers and install skills in Claude.

### Prerequisites

Before you begin, make sure you have:

- An account with administrator access for each Kaseya product you want to connect: Datto RMM, Autotask, or IT Glue.
- Claude Desktop.

### Setup: Connecting to MCP servers and skills
---
### Step 1: Generate credentials

Before connecting to MCP Servers, generate application programming interface (API) credentials for each platform. **Have all values on hand before proceeding to Step 2.**
> [!CAUTION]
> In the current version of the **IT Glue MCP server**, configuration grants the user access to **all the information available in the API.**
>
> To read more about **RMM and Autotask's API permissions**, see the following documentation:
>
> - [Datto RMM API v2 documentation](https://rmm.datto.com/help/en/Content/2SETUP/APIv2.htm)
> - [Autotask: How accessing Autotask data as the MCP API User currently works](https://ww15.autotask.net/help/DeveloperHelp/Content/APIs/General/Define_API_User.htm)
> - [Autotask: Tailoring the MCP API User's Security Level: Creating or editing a custom security level](https://ww15.autotask.net/help/Content/4_Admin/1CompanySettings_Users/ResourcesUsersHR/Security/Create_Edit_Custom_Security_Level.htm?cshid=1139)

| Product       | Values needed                                 | How to generate credentials                                                                            |
| ------------- | --------------------------------------------- | ------------------------------------------------------------------------------------------------------ |
| **Datto RMM** | Platform name and number, API Key, API Secret | [Generate API Key, Secret, and determine your platform number](GENERATING-API-KEYS.md#datto-rmm)       |
| **IT Glue**   | API Key                                       | [Generate API Key](GENERATING-API-KEYS.md#it-glue)                                                     |
| **Autotask**  | Username, secret, Autotask MCP endpoint       | [Generate username, secret, and determine your Autotask MCP endpoint](GENERATING-API-KEYS.md#autotask) |

> [!IMPORTANT]
> The [Kaseya API License](https://www.kaseya.com/legal/kaseya-api-license/) governs your use of any MCP server.
> **Do not share keys, and use minimally scoped permissions for each use case and user. Be aware** that, once connected, the AI services can:
>
> 1. Read and access the Content in your Kaseya product platform.
> 2. Create and update the Content in your Kaseya product platform.
>
> **AI services access Content exactly as the Kaseya product platform stores it. Content may include sensitive information such as usernames, passwords or other confidential data.**
>
> The [Kaseya Master Agreement](https://www.kaseya.com/legal/kaseya-master-agreement/) classifies AI services as Third Party Technology.

---

### Step 2: Connect to MCP servers and install skills in Claude Desktop

**Option 1: MCPB Bundle in Claude Desktop**

1. Download the MCPB Bundle (MCPB) file and skills ZIP file listed for each product you want to connect.

   | Product   | Files                                  | Link                                           |
   | --------- | -------------------------------------- | ---------------------------------------------- |
   | Autotask  | autotask-mcp.mcpb, autotask-plugin.zip | [Autotask folder](AUTOTASK)                    |
   | Datto RMM | datto-rmm.mcpb, Datto-RMM-plugin.zip   | [Datto RMM folder](RMM)                        |
   | IT Glue   | itglue-0.1.0.mcpb, itglue-plugin.zip, itglue-auth.ps1 | [IT Glue folder](ITGLUE)          |

2. Open Claude settings and navigate to **Extensions** in the left sidebar. Drag the MCPB file into Claude Desktop.

     If you can't drag the file, click **Advanced Settings**, click **Install Extension**, and then select the file in the window that opens.

3. Enter the credentials you generated in [Step 1](#step-1-generate-credentials) when prompted, and then click **Save**.
> [!NOTE]
> Claude Desktop shows extension settings and secrets values in its developer window once configured. Details [here](https://github.com/modelcontextprotocol/mcpb/issues/244). 

4. Enable the extension, or turn it off and on if it was already on.
5. Repeat steps 2 through 4 for each product you want to connect.
6. Upload the skills ZIP file for each product you connected:
   1. In Claude, click **Plugins** in the left sidebar.
   2. Click the **Plus** icon in the upper-right corner.
   3. Click **Upload File**, and then select the ZIP file you downloaded earlier.
   4. Click **Upload**.
   5. Repeat these steps for each product.
  
**Option 2: MCPB Bundle in Claude Code (CLI)**

**Datto RMM**

_Prerequisite:_ Node.js 22 or newer and Claude Code (the `claude` command). Check with `node -v` and `claude --version`; only if either is missing or older, install [Node.js](https://nodejs.org) 22 or newer or Claude Code.

1. Download the [RMM folder](RMM) and keep `datto-rmm.mcpb`, `Datto-RMM-plugin.zip` and the installer script together in the same folder.
2. Run the installer for your system:
   - **macOS / Linux:** `sh install-claude-code.sh`
   - **Windows:** run `install-claude-code.cmd` (or `install-claude-code.ps1` from PowerShell)
3. When prompted, choose your platform number (1-7) from the [platform list in Step 1](#step-1-api-credentials), then enter your Datto RMM API Key and API Secret.
4. The installer connects the `datto-rmm` MCP server to Claude Code (user scope) and installs the Datto RMM skills to `~/.claude/skills/datto-rmm`.
5. Start `claude` and ask: `List my Datto RMM sites.`

**Autotask**

1. Store your Autotask API credentials _(generated in [Step 1](GENERATING-API-KEYS.md#autotask))_, by running the `autotask-auth.ps1` script's `configure` verb from PowerShell:
   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\autotask-auth.ps1 configure
   ```
   `configure` does the following:
   - Prompts for the Autotask MCP endpoint _(found in the [Generating-API-Keys document](GENERATING-API-KEYS.md#autotask))_, which is the server's full URL, for example `https://mcp3.autotask.net/mcp`. The URL must start with `https://` and end with `/mcp`, or `configure` rejects it. Use the same URL in steps 2 and 3, in place of `<mcp-host>`.
   - Prompts for the Autotask API username, secret, and integration code. The secret and integration code are hidden as you type.
   - Stores the credentials encrypted for your Windows user only (DPAPI), in `%LOCALAPPDATA%\Kaseya\AutotaskMcp`.
2. Add the base HTTP entry:
   ```powershell
   claude mcp add --transport http --scope user autotask https://<mcp-host>/mcp
   ```
3. Open `%USERPROFILE%\.claude.json`, find the `"autotask"` entry in the top-level `"mcpServers"` object, and add `headersHelper`. Copy the `headersHelper` value from the entry that `configure` printed in step 1. The path in it is the absolute path to `autotask-auth.ps1` on this machine, with each backslash doubled for JSON. The entry has this shape:
   ```json
   "autotask": {
     "type": "http",
     "url": "https://<mcp-host>/mcp",
     "headersHelper": "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File \"<path-to>\\autotask-auth.ps1\" headers -Profile default"
   }
   ```
4. Run `claude mcp get autotask`. The output shows the entry and its scope.

**IT Glue**

_Prerequisite:_ Claude Code (the `claude` command) and the IT Glue API Key from [Step 1](GENERATING-API-KEYS.md#it-glue). Check with `claude --version`.

1. Store your IT Glue API key _(generated in [Step 1](GENERATING-API-KEYS.md#it-glue))_ by running the `itglue-auth.ps1` script's `configure` verb from PowerShell. Replace `NA` with `EU` or `AU` for those regions:
   ```powershell
   powershell.exe -NoProfile -ExecutionPolicy Bypass -File .\itglue-auth.ps1 configure -Region NA
   ```
   `configure` does the following:
   - Prompts for the IT Glue API key. The key is hidden as you type, and `configure` rejects a value that does not start with `ITG.`.
   - Stores the key encrypted for your Windows user only (DPAPI), in `%LOCALAPPDATA%\Kaseya\ItGlueMcp`.
2. Choose the IT Glue MCP endpoint for your region. Use that URL in this step and in step 3, in place of `<mcp-url>`:

   | Region | Endpoint                         |
   | ------ | -------------------------------- |
   | NA     | `https://mcp.itglue.com/mcp`     |
   | EU     | `https://mcp.eu.itglue.com/mcp`  |
   | AU     | `https://mcp.au.itglue.com/mcp`  |

   Add the base HTTP entry:
   ```powershell
   claude mcp add --transport http --scope user itglue <mcp-url>
   ```
3. Open `%USERPROFILE%\.claude.json`, find the `"itglue"` entry in the top-level `"mcpServers"` object, and add `headersHelper`. The path in it is the absolute path to `itglue-auth.ps1` on this machine, with each backslash doubled for JSON. Use the same region in `-Region` as in the URL: `NA`, `EU`, or `AU`. The entry has this shape:
   ```json
   "itglue": {
     "type": "http",
     "url": "<mcp-url>",
     "headersHelper": "powershell.exe -NoProfile -NonInteractive -ExecutionPolicy Bypass -File \"<path-to>\\itglue-auth.ps1\" headers -Region NA"
   }
   ```
   The helper prints the `x-api-key` and `MCP-Protocol-Version` headers when Claude Code connects, so the entry holds no key.
4. Run `claude mcp get itglue`. The output shows the entry and its scope.
5. Start `claude` and ask: `List my IT Glue organizations.`

> [!NOTE]
> `itglue-auth.ps1` needs Windows PowerShell 5.1, which every supported Windows version includes. It does not work on macOS or Linux.

---

## Supported clients

| Client         | Supported |
| -------------- | --------- |
| Claude Desktop | ✅        |
| Claude Code (CLI)    | ✅        |

---

## Supported products and tools

| Product       | What skills can do                                                                 |
| ------------- | ---------------------------------------------------------------------------------- |
| **Datto RMM** | Run components and scripts, triage alerts, check device health, and audit hardware |
| **IT Glue**   | Build site-visit packs, score a client’s documentation, and review documentation and asset health |
| **Autotask**  | Read and update tickets, post notes, and provide ticket briefings                  |

---

## Kaseya tools & skills

Skills in the Kaseya community come in two levels of complexity, and they work together.

- **Tools** do one specific thing — read a ticket, check whether a device is online, post a note, or run a script. Tools are simple, fast, and useful on their own.

- **Skills** are complete workflows. They string tools together in the right order to handle an entire process from first look to final documentation, and you approve the key steps along the way.

Run any tool or skill on its own, outside of a workflow, whenever you need it.

Follow this approach as you explore tools and skills with MCP servers:

1. Start with simple query tools (read).
2. Move to simple update tools (write, with guardrails).
3. Progress to simple skills as workflows.

## Kaseya MCP tools

### Autotask

| Tool                | Operation | Description                                                                                                                         |
| ------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------- |
| **search-entities** | Read      | Find the Autotask entity name that matches a plain-language description.                                                            |
| **describe-entity** | Read      | Return the live field schema: field names, data types, flags, picklist values, and supported operators.                             |
| **query-entity**    | Read      | Query an entity with filters, one `anyOf` group, fields, and a limit. Return rows in identifier (ID) order, with a `nextPage` hint. |
| **count-entities**  | Read      | Count rows that match the filters, without fetching them.                                                                           |
| **get-entity**      | Read      | Get one row by numeric ID. Return `found: false` if no row has that ID.                                                             |
| **search-tickets**  | Read      | Search tickets by company, status, title, assignment, and date. No query DSL needed. Default to open tickets.                       |
| **get-ticket**      | Read      | Get one ticket by ID, with full detail in ticket vocabulary.                                                                        |
| **create-entity**   | Write     | Create a row, read it back, and return it enriched. Do not resend the create request to check whether it worked.                    |
| **update-entity**   | Write     | Update one row by ID, read it back, and return it enriched.                                                                         |
| **delete-entity**   | Write     | Permanently delete one row. Only working rows and link rows accept a delete — business records never do.                            |
| **add-ticket-note** | Write     | Add a note to an existing ticket. Return the note, read back and enriched.                                                          |

See [Autotask Documentation](AUTOTASK/Autotask-Skills-documentation.md#entities) to see which entities are included in MCP servers.

### Datto RMM

| Tool                     | Operation       | Description                                                                                                                                                |
| ------------------------ | --------------- | ---------------------------------------------------------------------------------------------------------------------------------------------------------- |
| **list_sites**           | Read            | Retrieve a paginated list of sites in the authenticated Datto RMM tenant.                                                                                  |
| **get_site**             | Read            | Retrieve detailed information about a specific site.                                                                                                       |
| **list_devices**         | Read            | List and search managed devices, with optional site, device filter, hostname, device ID, or MAC address filtering.                                         |
| **get_device**           | Read            | Retrieve detailed information about a specific managed device.                                                                                             |
| **get_device_audit**     | Read            | Retrieve hardware, storage, network, and operating-system audit information for a device.                                                                  |
| **list_device_software** | Read            | Retrieve a paginated list of audited software installed on a device.                                                                                       |
| **list_patches**         | Read            | Retrieve patch information for a device or site, including installation and approval status.                                                               |
| **list_activity_logs**   | Read            | Retrieve activity history scoped by device, device filter, or account, with time-range filtering and cursor pagination.                                    |
| **list_device_filters**  | Read            | Retrieve available default, custom, or site-specific device filters.                                                                                       |
| **update_device_udfs**   | Write           | Update selected device user-defined fields without modifying omitted fields. Preview changes by default; require explicit confirmation to apply them.      |
| **list_components**      | Read            | Retrieve a paginated catalog of automation components available for execution.                                                                             |
| **create_job**           | Write / Execute | Execute an automation component on a device and return the created job UID. Preview execution by default; require explicit confirmation to submit the job. |
| **get_job_status**       | Read            | Retrieve job status, device-specific execution results, and available standard output and error output.                                                    |
| **list_alerts**          | Read            | Retrieve paginated open or resolved monitoring alerts for a device, site, or account.                                                                      |
| **get_alert**            | Read            | Retrieve details of a specific monitoring alert.                                                                                                           |
| **resolve_alert**        | Write           | Resolve a monitoring alert. Previews the action by default; requires explicit confirmation and leaves already-resolved alerts unchanged.                   |

### IT Glue

| Tool                                    | Operation | Description                                                                                                                                     |
| --------------------------------------- | --------- | ----------------------------------------------------------------------------------------------------------------------------------------------- |
| **list_organizations**                  | Read      | List organizations with optional filtering, exclusion, range filtering, sorting, and related-resource includes.                                 |
| **search_organizations** (experimental) | Read      | Find organizations by name and get their organization ID. Returns best matches first, limited to the top results.                               |
| **get_organization**                    | Read      | Retrieve a specific organization by ID, with optional related resources.                                                                        |
| **list_configurations**                 | Read      | List configurations, filterable by ID, name, serial number, MAC address, asset tag, archived state, and PSA/RMM IDs, with sorting and includes. |
| **get_configuration**                   | Read      | Retrieve full details of a configuration by ID, with optional sideloaded relationships.                                                         |
| **list_documents**                      | Read      | List document metadata (no content) in an organization, optionally filtered by folder.                                                          |
| **search_documents** (experimental)     | Read      | Search document names (not content) in one organization across all folders. Returns best matches first.                                         |
| **get_document**                        | Read      | Retrieve a complete document by ID, including metadata and all sections.                                                                        |
| **list_document_folders**               | Read      | List an organization's document folders: all, root-level only, or the direct children of a folder.                                              |

## Skills

The following skills for Claude Desktop automate Datto RMM, Autotask, and IT Glue workflows, with no coding required. This guide walks through each skill and what to expect when you use it, so your team can start saving time immediately.

| Product   | Skill                                                                                    | What it automates                                                                                                                                                                                                                               |
| --------- | ---------------------------------------------------------------------------------------- | ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| Autotask  | [autotask-briefing](AUTOTASK/Autotask-Skills.md#autotask-briefing)                       | Assembles a complete briefing on one Autotask record and everything attached to it. Use this skill to understand, summarise, or get context on a ticket, company, contact, or device.                                                           |
| Autotask  | [autotask-guarded-changes](AUTOTASK/Autotask-Skills.md#autotask-guarded-changes)         | Controls every change to Autotask data. Reads the record first, proposes the change for you to confirm, then sends each write once, and reports what Autotask holds afterward.                                                                  |
| Datto RMM | [drmm-morning-pulse](RMM/DRMM-Skills-documentation.md#morning-pulse)                     | Reads devices, open alerts, overnight resolved alerts, and the overnight activity log; separates new overnight drops from long-dead gear, spots servers about to fail, and gives you a plan ranked by customer impact.                          |
| Datto RMM | [drmm-device-quick-look](RMM/DRMM-Skills-documentation.md#device-quick-look)             | Finds the device by hostname, part of a name, MAC address or ID; reads its record, hardware, alerts, patches, software, and recent activity; trends disk space and groups repeating alerts.                                                     |
| Datto RMM | [drmm-patch-posture](RMM/DRMM-Skills-documentation.md#patch-posture)                     | Reads patch status across servers and workstations, names failing and pending updates, and flags conditions that will break the next patch cycle (such as disk full or servicing errors).                                                       |
| Datto RMM | [drmm-stale-and-ghost-devices](RMM/DRMM-Skills-documentation.md#stale-and-ghost-devices) | Finds long-offline devices, ghosts (re-imaged or renamed machines left behind, duplicate enrollments), suspended agents, and sites holding only dead records, with an estimate of the seats involved.                                           |
| Datto RMM | [drmm-security-coverage-gaps](RMM/DRMM-Skills-documentation.md#security-coverage-gaps)   | Vendor-neutral: checks antivirus presence, running state and updates; finds EDR and MDR agents through device filters; and flags conflicting products. Provides per-site figures you can hand to a customer or an insurance questionnaire.      |
| Datto RMM | [drmm-device-timeline](RMM/DRMM-Skills-documentation.md#device-timeline)                 | Builds one timeline from the activity log (jobs, patches, remote sessions, changes) and alerts, marks what happened just before the problem, and states timing, never blame. Suggests which Windows event log entries you should check.         |
| Datto RMM | [drmm-alert-noise-review](RMM/DRMM-Skills-documentation.md#alert-noise-review)           | Groups recent alerts by type and device, scores the noise (self-resolving, flapping, same time every day, tickets nobody needed, alerts on dead gear), and recommends a specific tuning step — while protecting alerts that are noisy but real. |
| Datto RMM | [drmm-software-finder](RMM/DRMM-Skills-documentation.md#software-finder)                 | Groups devices by version and site, rates versions current, behind, or end of life against the vendor's latest release, and can look for shadow IT (remote-control tools, personal VPNs, P2P, other RMMs) or a whole category of software.      |
| Datto RMM | [drmm-os-lifecycle](RMM/DRMM-Skills-documentation.md#os-lifecycle)                       | Checks every device's OS and build against live end-of-life dates for Windows, Windows Server, macOS, common Linux distributions, and ESXi; marks paid extended updates where possible; prioritizes servers first.                              |
| IT Glue | [itglue-organization-overview](ITGLUE/ITGlue-Skills-documentation.md#itglue-organization-overview)                | Builds a one-page site pack of network gear, internet details, printers, site documents, and ticket hints, with gaps flagged.      |
| IT Glue |  [itglue-hygiene-check](ITGLUE/ITGlue-Skills-documentation.md#itglue-hygiene-check)                | Creates a scorecard of one client's documentation quality plus what to fix first.       |
| IT Glue | [itglue-environment-review](ITGLUE/ITGlue-Skills-documentation.md#itglue-environment-review)                | Produces a Documentation and Asset Health Review report for one client. Contains the following: summary, environment at a glance, lifecycle, security documentation, document health, data quality, recommended actions, and  what is not covered.       |

## FAQs

| Category | Question | Answer |
|----------|----------|--------|
| Roadmap, identity, and security | **Will this expand to a unified data layer rather than individual platform connectors? Is there a timeline for a single Kaseya MCP so we don't repeat the setup for every product?** | Unified APIs are planned for FY27. Unified Kaseya Claude connector is also in the roadmap. |
| Roadmap, identity, and security | **Which Kaseya products have MCP servers, and will others (MDR, EDR, RapidFire Tools, Inky, Kaseya SIEM, Smart Insights, etc.) be added?** | Early Access covers Autotask, Datto RMM and IT Glue MCP servers. We do not have a timeline for other products at this time. |
| Roadmap, identity, and security | **When will the MCP servers be generally available? Is this open to all customers?** | Kaseya plans to open the servers to all customers but is calling it early access until we have OAuth 2.1 support, which is the FY27 roadmap. We currently are planning to release this early access to all customers. |
| Roadmap, identity, and security | **Is an MCP gateway planned so I do not have to give every technician an API key or share one key across my team? How will this scale beyond a single administrator?** | Yes, this work is in progress. Kaseya is unifying user identity with API identity and putting all APIs behind OAuth 2.1, and then will release MCP connectors that do not require you to use API keys. The target is FY27. Until then, please generate a separate API key for each person or role. For example, create one read-only API user for technicians and one read/write API user for power users. |
| Roadmap, identity, and security | **Can I limit what each individual user can do through the MCP, instead of everything the API user can do?** | The MCP server access is tied to the API key. |
| Roadmap, identity, and security | **What is the limit for calls through the MCP servers?** | The limit is the same as your account's API throttling limit. |
| Setup and connectivity | **Can I connect to the MCP servers using a different platform than Claude (CoPilot, ChatGPT)?** | You are welcome to use any AI tool to connect to our MCP servers, but we are certifying it for Claude Desktop and Claude Code. Kaseya cannot assist with any troubleshooting relating to connections with different AI tools. |
| Setup and connectivity | **What do I need in place before I can connect?** | Claude Desktop installed, access to the GitHub repo, and your API credentials generated for each product. The repo README is the source of truth covering these steps - begin with #Getting-started covering the pre-reqs. |
| Setup and connectivity | **Claude shows a red warning when I install the extension. Is this running anything on my computer?** | No. The Kaseya MCP server is remote. The extension only connects Claude to it and does not do anything on your desktop or file system. Anthropic shows this warning for every extension. |
| Setup and connectivity | **I get an error dragging the .mcpb file into Claude.** | Re-download it; the file likely didn't download fully. |
| Setup and connectivity | **Which Claude plan is enough for this? (Hit the free usage limit.)** | It depends on your usage and Anthropic agreement. |
| Setup and connectivity | **How do I know whether the connection worked? I saved my credentials and nothing happened.** | There is no success message. Toggle the extension from Disabled to Enabled: if it turns blue/Enabled it connected; if not, an error appears (post it in the chat, Teams or Discord). Open Configure to confirm: you should see the list of Autotask read and write tools. If you fix a setting (for example adding https:// to the URL), toggle it off and on again. Once enabled, open a chat and ask in natural language; Claude chooses the tools itself. |
| Setup and connectivity | **Is there documentation for setting up skills? Which files do I download, and where do I upload them?** | Yes. Follow [Step 2](#step-2-connect-to-mcp-servers-and-install-skills-in-claude-desktop) in this README. For each product, download the MCPB file and the plugin ZIP file from the product folder. Add the MCPB file under **Extensions**, and then upload the plugin ZIP file under **Plugins**. The plugin ZIP file contains the skills for that product. Common mix-up: Claude has a **Skills** section, but you upload Kaseya skills as plugins. |
| Setup and connectivity | **Where do I generate the API keys for each product?** | See [Generating API keys](GENERATING-API-KEYS.md), which includes detailed steps and screenshots for each product, and the Autotask zone and endpoint lookup. |
| Setup and connectivity - Autotask | **Which MCP endpoint do I use (e.g. mcp2 vs mcp3)? If my Autotask URL is ww14, should I use https://mcp14.autotask.net/mcp?** | It depends on your Autotask zone. Take your Autotask API host, replace "webservices" with "mcp" and add "/mcp" (e.g. webservices3 → https://mcp3.autotask.net/mcp). The zone lookup can be found [here](Generation-API-Keys.md). Correct format must include https:// at the front. |
| Setup and connectivity - Autotask | **Why is my Autotask MCP server URL not accepted, or why does the connection fail?** | You must include `https://` at the front of the URL, and the URL must end with `/mcp`. For example, `https://mcp3.autotask.net/mcp`. |
| Setup and connectivity - Datto RMM | **Why is the Datto RMM MCP server installed in the Organization settings, not at the user level like the Autotask MCP server?** | For Datto RMM, the client is a stdio bridge, which runs locally on each user's machine. Each user's Claude Desktop runs its own copy, so you cannot install it once at the organization level. An admin can still deploy the extension to everyone through Claude Desktop's managed extensions. Each user then enters their own API credentials. |
| Setup and connectivity - Datto RMM | **Is the Datto RMM MCP server available in my region?** | Yes. All Datto RMM MCP servers are deployed, and all regions should be supported. |
| Setup and connectivity - Datto RMM | **Datto RMM connects, but my queries fail with a 403 Forbidden error, for example when I ask how many sites I have. What do I do?** | A 403 error means Datto RMM accepted your API key, but the API user doesn't have sufficient permissions for this request. To resolve this, go to Setup > Users, locate the user that owns the API key, and assign an API Security Level with the appropriate permissions. The Administrator level provides full access, so we recommend using it only when necessary. For more details on API permissions and setup, please see the Datto RMM API v2 documentation: (https://rmm.datto.com/help/en/Content/2SETUP/APIv2.htm).|
| Setup and connectivity - IT Glue | **Is the IT Glue MCP server available in my region, and what do I enter for the region?** | Yes. The IT Glue MCP servers are available in all regions: Australia, Europe, and North America. The IT Glue configuration panel states at the top what to enter for each region. |
| Setup and connectivity - IT Glue | **IT Glue shows the error "IT Glue rejected the credential, or MCP is not enabled for this account," even after I regenerate my API key. What do I do?** | During early access, the IT Glue product team turns on MCP for each account with a feature flag. If you see this error, your account most likely does not have MCP turned on yet, rather than having a bad key. If the error continues, post in Teams or Discord, or join an office hour, so the IT Glue team can check your account. |
| Capabilities and limitations - Autotask | **Can the MCP do a global notes search?** | No. Global Notes Search, as it exists in the Autotask user interface (UI), is not an API endpoint, so it is not in the initial MCP. You can retrieve notes tied to a specific ticket, company, or device by using the autotask-briefing skill. Currently, you can query only `ticketNotes`. |
| Capabilities and limitations - Autotask | **Can the MCP audit my workflow rules?** | No. Workflow rules are not an entity in the API, so the MCP cannot audit them. Autotask has a built-in workflow audit function in the UI, on the workflow page, that finds redundant and unused workflows. |
| Capabilities and limitations - Autotask | **Can a workflow change the company on a ticket?** | No. Workflow rules cannot change the company on a ticket, by design. You can change the company ID through the API, and so through the MCP, as long as the ticket has no billing dependencies, such as time entries, expenses, or ticket charges (especially posted ones). The UI has the same restriction. For email processing, put `//` followed by the exact company name in the ticket body so that Autotask matches the account. |
| Capabilities and limitations - Autotask | **Can I create a dashboard to share with a client?** | A dashboard is a Claude artifact, so you can share the output, such as a PDF download or HTML. |
| Capabilities and limitations - Autotask | **Can the MCP export data, such as issues and sub-issues, to Excel?** | Yes. Prompt Claude to create the insights you want in an Excel file, and then download it. For example, Claude can create a summary of issues and sub-issues. |
| Capabilities and limitations | **Can the MCP update IT Glue documentation from ticket information once the products are linked?** | Cross-product workflows are the long-term goal. Currently, skills work within a single product only. |
| Capabilities and limitations | **What skills does Kaseya provide, and how do they work?** | See the [Skills](#skills) section of this README for the full list, and [Kaseya tools and skills](#kaseya-tools--skills) to learn how skills work. For details about each skill, see the skills documentation in each product folder: [Autotask](AUTOTASK/), [Datto RMM](RMM/), and [IT Glue](ITGLUE/). |
| Capabilities and limitations | **Can I control which actions Claude can take, such as read versus write or delete?** | Yes. After you install the extension, open **Configure**. Separate dropdowns control read tools and write/delete tools. While you test, select **Needs Approval** for both. Once you trust the read tools, select **Always Allow** for read tools, and keep write/delete tools on **Needs Approval**. The same settings apply to Kaseya skills, so a skill that writes still asks for permission first. Try read queries before you write to production. |
| Capabilities and limitations | **Are there example prompts to get started?** | Yes. See the skills documentation in each product folder for example prompts that invoke each skill: [Autotask](AUTOTASK/), [Datto RMM](RMM/), and [IT Glue](ITGLUE/). |
| Capabilities and limitations | **Can I build my own skills or routines on top of the MCP tools?** | Yes. You are welcome to build your own skills from the tools. Tip: add your existing knowledge base (KB) articles to Claude and ask it to create a skill from them. Some customers plan to schedule routines (for example, in Claude Cowork) once write access is turned on. We would love to have you share your skills in Discord. Community show-and-tell sessions are planned; see Discord for the schedule. |
| Capabilities and limitations | **Why does my output, such as a dashboard or table, look different from what others show?** | In Claude, your account instructions, as well as your past usage history, leads to the same prompt on the same data showing different output. |
| Other AI platforms, strategy, and community | **Can I use the MCP servers with Copilot Studio, ChatGPT, or my own custom agent? Can I load the `.mcpb` files as-is?** | Kaseya supports Claude Desktop and Claude Code. Copilot Studio can connect to the MCP servers, and Kaseya plans official support in FY27. Until then, Kaseya cannot provide troubleshooting or instructions for other AI tools because the materials are written for Claude, but you are welcome to try the repo and share your results with the community on Discord. The `.mcpb` files work only with Claude. For Copilot Studio, follow Microsoft's documentation to add the endpoint. For a custom agent, write code that calls the endpoint with your credentials. Kaseya has no guidance for ChatGPT at this time. |
| Other AI platforms, strategy, and community | **Why does Kaseya offer an MCP instead of in-app native tools, API-only access, or letting customers build their own?** | Customers already make billions of API calls each month, and many asked for official MCP servers to use with their agents and Claude. |
| Other AI platforms, strategy, and community | **What is the roadmap beyond the early access, and will Kaseya share it?** | Yes, Kaseya will share the roadmap. Focus areas include OAuth 2.1 support for APIs, with Anthropic connectors to follow, and Kaseya Insights and actions inside the product. |
| Other AI platforms, strategy, and community | **Do MCP calls count against my hourly API call limit, and is there a charge?** | The MCP servers are free, and calls through them are subject to your account's API throttling limit. In the future, Kaseya may begin charging for API calls above a certain high threshold. |
| Other AI platforms, strategy, and community | **How should I share skills and prompts with the group?** | Share in the MCP servers channel in Discord! Kaseya will host show-and-tell community sessions; see Discord for the schedule. |
| Program, support, and feedback | **When are office hours, and what are they for?** | Office hours Mondays and Wednesdays from 11:00 AM to 12:00 PM Eastern for the duration of the alpha. Drop in and out any time for live demos, troubleshooting, access to product managers to discuss use cases, and time with other customers. Special sessions focus on sharing skills and prompts and on customers trying tools other than Claude. If office hours are not on your calendar, email sarah.tappan@kaseya.com. |
| Program, support, and feedback | **How do I contact the team, give feedback, or request features?** | Use the Teams channel **MCP Servers pre-alpha - General** or Discord. Discord will be the main community after the program. You can also [book a 1:1 feedback session](https://calendly.com/billing-kaseya-one/mcp-server-pre-alpha-program-feedback-session). Expect a weekly survey and a post-kickoff survey. Feature requests are welcome in any of these channels. |
| Program, support, and feedback | **Will I get a recording of the kickoff session? I missed some of the install steps.** | Yes, Kaseya will share recordings with the group. You can also follow the steps in [Getting Started](#getting-started) and drop into office hours for help. |
| Kaseya Insights | **What is Kaseya Insights, and can I join?** | Kaseya Insights is a new platform capability with its own alpha program, built for MSP owners and administrators. It answers business and operational questions through a conversational interface inside KaseyaOne. It currently answers 100 to 200+ questions across Autotask and Datto RMM, with more products coming. The Insights alpha starts in mid-November. Everyone in North America can join. |

## Legal documents

The Kaseya Insights Community operates under a set of governing documents. All Participants are expected to read and comply with the documents applicable to their activities.

| Doc | Purpose |
| --------- | ---------------------------------------------------------------------------------------- |
|[License](LICENSE.md)|Apache License, Version 2.0. Governs all contributions to the community.|
|[Code of Conduct](Governance/CODE_OF_CONDUCT.md)|Community standards and enforcement policy. Applies to all community spaces and Participants.|
|[Governance Policy](Governance/GOVERNANCE.md)|Community structure and roles.|
|[Security Policy](Governance/SECURITY.md)|How to report security vulnerabilities privately. Do not post vulnerability reports in public issues or forums.|
|[Disclaimers](Governance/DISCLAIMERS.md)|Consolidated disclaimers and claim waivers applicable to all community activities and Participants.|
