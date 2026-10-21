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
4. [Example Tools & Skills](#example-tools--skills)
5. [RMM Resources](RMM/)
6. [Autotask Resources](AUTOTASK/)
7. [IT Glue Resources](ITGLUE/)
8. [Disclaimer](Governance/DISCLAIMERS.md#disclaimers-and-claim-waivers)
9. [Security](Governance/SECURITY.md)
10. [Code of Conduct](Governance/CODE_OF_CONDUCT.md)
11. [Governance Policy](Governance/GOVERNANCE.md)

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

#### Step 1: Generate credentials

Before connecting to MCP Servers, generate application programming interface (API) credentials for each platform. **Have all values on hand before proceeding to Step 2.**

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

#### Step 2: Connect to MCP servers and install skills in Claude Desktop

**Option 1: MCPB Bundle in Claude Desktop**

1. Download the MCPB Bundle (MCPB) file and skills ZIP file listed for each product you want to connect.

   | Product   | Files                                  | Link                                           |
   | --------- | -------------------------------------- | ---------------------------------------------- |
   | Autotask  | autotask-mcp.mcpb, autotask-plugin.zip | [Autotask folder](AUTOTASK)                    |
   | Datto RMM | datto-rmm.mcpb, Datto-RMM-plugin.zip   | [Datto RMM folder](RMM)                        |
   | IT Glue   | itg-mcp.mcpb, itglue-plugin.zip        | [IT Glue folder](ITGLUE)                       |

2. Open Claude settings and navigate to **Extensions** in the left sidebar. Drag the MCPB file into Claude Desktop.

     If you can't drag the file, click **Advanced Settings**, click **Install Extension**, and then select the file in the window that opens.

3. Enter the credentials you generated in [Step 1](#step-1-generate-credentials) when prompted, and then click **Save**.
4. Enable the extension. Repeat steps 2 through 4 for each product you want to connect.
5. Upload the skills ZIP file for each product you connected:
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

_Prerequisite:_ Claude Code (the `claude` command) and the IT Glue API Key from [Step 1](#step-1-generate-credentials). Check with `claude --version`.

1. Choose the IT Glue MCP endpoint for your region by replacing `<REGION>` with `na`, `eu`, or `au`:
   `https://mcp.<REGION>.itglue.com/mcp`
2. Add the server to Claude Code (user scope), replacing `<REGION>` and `YOUR_API_KEY`:
   ```bash
   claude mcp add --transport http --scope user itglue https://mcp.<REGION>.itglue.com/mcp \
     --header "x-api-key: YOUR_API_KEY" \
     --header "MCP-Protocol-Version: 2026-07-28"
   ```
   Alternatively, add the entry manually to the top-level `"mcpServers"` object in `~/.claude.json` (`%USERPROFILE%\.claude.json` on Windows):
   ```json
   "itglue": {
     "type": "http",
     "url": "https://mcp.<REGION>.itglue.com/mcp",
     "headers": {
       "x-api-key": "YOUR_API_KEY",
       "MCP-Protocol-Version": "2026-07-28"
     }
   }
   ```
3. Run `claude mcp get itglue`. The output shows the entry and its scope.
4. Start `claude` and ask: `List my IT Glue organizations.`

> [!WARNING]
> The API key is stored in plain text in `~/.claude.json`. Do not share or commit this file.

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

## Example tools & skills

Skills in the Kaseya community come in two levels of complexity, and they work together.

- **Tools** do one specific thing — read a ticket, check whether a device is online, post a note, or run a script. Tools are simple, fast, and useful on their own.

- **Skills** are complete workflows. They string tools together in the right order to handle an entire process from first look to final documentation, and you approve the key steps along the way.

Run any tool or skill on its own, outside of a workflow, whenever you need it.

Follow this approach as you explore tools and skills with MCP servers:

1. Start with simple query tools (read).
2. Move to simple update tools (write, with guardrails).
3. Progress to simple skills as workflows.

## Common MSP tools

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
| Datto RMM | [drmm-od-lifecycle](RMM/DRMM-Skills-documentation.md#od-lifecycle)                       | Checks every device's OS and build against live end-of-life dates for Windows, Windows Server, macOS, common Linux distributions, and ESXi; marks paid extended updates where possible; prioritizes servers first.                              |

## Legal documents

The Kaseya Insights Community operates under a set of governing documents. All Participants are expected to read and comply with the documents applicable to their activities.

| Doc                                   | Purpose                                                                                                         |
| ------------------------------------- | --------------------------------------------------------------------------------------------------------------- |
| [License](LICENSE.md)                 | Apache License, Version 2.0. Governs all contributions to the community.                                        |
| [Code of Conduct](CODE_OF_CONDUCT.md) | Community standards and enforcement policy. Applies to all community spaces and Participants.                   |
| [Governance Policy](GOVERNANCE.md)    | Community structure and roles.                                                                                  |
| [Security Policy](SECURITY.md)        | How to report security vulnerabilities privately. Do not post vulnerability reports in public issues or forums. |
| [Disclaimers](DISCLAIMERS.md)         | Consolidated disclaimers and claim waivers applicable to all community activities and Participants.             |
